---
title: Kafka Replication Deep Dive
date: 2017-12-20 21:00 JST
tags: kafka
---

この記事は [Distributed computing Advent Calendar 2017](https://qiita.com/advent-calendar/2017/distributed-computing) 20日目の記事です。

![Apache Kafka Logo](kafka.png)

Kafkaのレプリケーションは、高可用性と高信頼性を実現するための、重要な機能の1つです。
この記事では、Kafkaのレプリケーションの仕組みについて紹介します。

レプリケーションの基礎
----------------------

Kafkaのデータストリームの最小単位はパーティションです。またレプリケーションもパーティション単位で行われます。
Kafkaのレプリケーションの情報は、ZooKeeper上に保存されています。
レプリカの配置情報は、`${prefix}/brokers/topics/${topic}` にJSONで保存されます。

```json
{"version":1,"partitions":{"0":[0,1],"1":[1,2]}}
```

トピック作成時にはレプリカ数を指定します。
たとえば、Kafka付属の `kafka-topics.sh` では `--replication-factor` で指定します。

     bin/kafka-topics.sh \
        --zookeeper my-zookeeper:2181/${prefix} --create \
        --topic my-topic --partitions 2 \
        --replication-factor 3

またトピックを自動作成するときは、ブローカーの設定で `default.replication.factor` を指定します。

Kafkaのレプリカは、どれか1つが**リーダー**となり、Producer・Consumerからの読み書きを処理します。
クライアントがリーダー以外のパーティションに対して読み書きを行おうとすると。ブローカーは`NotLeaderForPartition` を返します。
リーダー以外のレプリカは**フォロワー**と呼びます。
フォロワーはリーダーiらメッセージを取得して、レプリケーションします。
リーダーはクライアントからのリクエスト処理以外にも、フォロワーのレプリケーション状況の管理などもします。

フォロワーがリーダーに追いついているレプリカを、**in-syncレプリカ (in-sync replica : ISR)** と呼びます。
ネットワークの瞬断などで、レプリケーションに遅延が発生することがあります。
フォロワーのレプリケーションがある一定以上送れると、in-sync replicaではなくなることもあります。
またリーダーもin-sync replicaです。

メッセージがKafkaに保存されるまで
---------------------------------

ProducerがKafkaに書き込んだデータは、Consumerはすぐに読み込めるというわけではありません。
もしそれが可能なら、Consumer間で処理するデータの一貫性が失われるからです。

Kafkaのキューには**high water mark**という概念があります。
high water markは「ここまではデータが保証されている」という印で、Consumerはhigh water markまでのデータのみ取得できます。
Producer書き込み時に、全てのin-sync replicaがメッセージを受け取ると、high water markが進みます。
そのとき全てのin-sync replicaが書き込めたメッセージは**コミット**された、とよびます（オフセットのコミットとは異なるので注意）。

![High water mark](high-water-mark.png)  
<p style='text-align: center; font-style:italic'>
  Consumerはin-sync replicaに保存されたデータのみ取得できる (Kafka: The Definitive Guideより)
</p>

もしhigh water markという概念がないとどうなるでしょうか。
あるConsumer *C*が図中のreplica 0のMessage 4を取得できたとします。
その後Replica 0を持つブローカーがクラッシュしてデータが失われたとします。
するとMessage 4が永久に失われ、結果として*C*と他のConsumerで取得できるメッセージで不整合が生じます。
Kafkaはhigh water markまでのメッセージを読み込めるようにすることで、Consumer間の一貫性を保ちます。

acks
----

Producerは信頼性向上のために、メッセージを保存する時にin-sync replicaに保存されるまで待つことができます。
`acks=all` が設定されていると、Producerは全ての in-sync replicaにメッセージが書かれるまで待ちます。
そして、仮にin-sync replicaの数が `min.insync.replicas` に満たない時、Producerはデータを書き込むことができません。

`acks=1` は、リーダーのみに書き込まれた時点で、Producerにackを返します。
このとき、in-sync replicaの数が `min.insync.replicas` より少なくても、Producerはメッセージを書き込まれたものとして扱います。
またリーダーのみがメッセージを持っている状態でクラッシュすると、データを失う可能性があります。
`acks=0` は、Producerのソケットバッファに追加されると、Producerは送信したとみなします。
これは非常にスループットは高いですが、信頼性は低いので使うことをおすすめしません。
たとえば送り先がリーダーじゃない場合でも、Producerはネットワークに書き込みをした時点で送信できたことになるので、データを失う可能性が非常に高いです。

ここで、あるレプリカのフォロワーが、ネットワーク遅延でin-sync replicaから外れた状況を考えます。
high water markの定義に従うと、全てのin-sync replicaはリーダーのみとなり、リーダーがメッセージを受け取るとコミットされます。
これは正しい動作ですが、そのメッセージを持つのはリーダーのみなので、信頼性を保証できません。
これを防ぐために、ブローカーに `min.insync.replicas` を設定します。
ブローカーの設定 `min.insync.replicas` は、書き込みするin-sync replicaの最小数を指定できます。
たとえば `min.insync.replicas=2` に設定すると、`in-sync replica` が最低限2つ存在することを要求するので、in-sync replicaがリーダーのみの場合メッセージを書き込めません。
このときブローカーはProducerに `NotEnoughReplicas` を返します。

ブローカー故障時の復帰処理
--------------------------

Kafkaはブローカーは耐故障性と可用性のためにレプリケーションします。
Kafkaは他の分散システムのように、ブローカー故障時したとき、別のノードに最レプリケーションは行われません。
ブローカーが故障したとしても、レプリカの配置情報は、ZooKeeperに残り続けます。
なのでノードが復帰した時、続きをリーダーから取得すれば良いので、高速にクラスタを復帰できます。
リーダーが故障すると、残った別のin-sync replicaから、新たなリーダーが再選出されます。

上記のin-sync replicaからのリーダー選出は、"clean"なリーダー選出と呼ばれ、データロスやデータの不整合は発生しません。
他のin-sync replicaが存在しないときにリーダーが故障すると、次のリーダーが選出されないのでパーティションは停止します。
このときin-sync replicaだったレプリカが復活するまで、パーティションは停止したままです。
可用性を優先する場合、in-syncではないレプリカからのリーダー再選出を許すことができます（これを"unclean"なリーダー選出と呼ぶ）。
ブローカーに `unclean.leader.election.enable=true` を設定するとで有効にできます。
ただし"unclean"なリーダー選出を有効にすると、データロスやConsumerごとのデータ不整合などが発生する可能性があります。
なので可用性を優先しない限り有効化するべきでは無いです。

まとめ
------

以上の設定は、Kafkaの信頼性や可用性を担保するために必要なパラメータです。
システムの目的により、 これらのパラメータの値を調整する必要があります。
また信頼性や可用性は、 リソースのキャパシティやスループットとトレードオフの関係にあります。
たとえばレプリカ数を増やすと、耐故障性は向上しますが、必要なディスク容量も増えます。

Kafka Documentの[A Production Server Config](https://kafka.apache.org/documentation/#prodconfig) には、
例として `min.insync.replicas=2` `default.replication.factor=3` が設定されてます。
これで、可用性については1ノードの故障まで耐えれます。データ損失に対しては2ノードまでの故障に耐えれます。

Kafkaではメッセージがコミットされるタイミングは、ディスクに書かれたタイミングではないです。
なのでシビアなタイミングでクラッシュするとデータが消える恐れがあります。
`flush.ms`, `flush.messages` を設定してfsyncの間隔を設定することで、さらに信頼性の高いシステムも構築できます。

参考文献
--------

- [Kafka: The Definitive Guide - O'Reilly Media](http://shop.oreilly.com/product/0636920044123.do)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka Replication - Apache Kafka](https://cwiki.apache.org/confluence/display/KAFKA/Kafka+Replication)
