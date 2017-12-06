---
title: Kafkaの管理ツールを読む - kafka-topics.sh編
date: 2017-12-06 20:00 JST
tags: scala, kafka
---

この記事は [Distributed computing Advent Calendar 2017](https://qiita.com/advent-calendar/2017/distributed-computing) の6日目の記事です。

![Apache Kafka Logo](kafka.png)

Apache Kafkaにはクラスタの管理ツールが含まれており、ユーザはこれらのツールを使ってトピックやオフセットを管理できます。
コードは規模的にもあまり大きくないので、Kafkaの勉強にはちょうどいい教材です。
Kafkaの内部構造を知ることで、障害発生時に原因を特定しやすくなります。

この記事では、トピック管理用の `kafka-topics.sh` の、よく使う以下の4つの操作を追ってゆきます。
なお今回読むコードは、[1.0.0](https://github.com/apache/kafka/tree/1.0.0)を対象にします。

```sh
# トピックの一覧表示
kafka-topics.sh --list --zookeeper localhost:2181/kafka 

# トピックの作成
kafka-topics.sh --create --zookeeper localhost:2181/kafka --topic new-topic --partitions 3 --replication-factor 1

# トピックの詳細表示
kafka-topics.sh --describe --zookeeper localhost:2181/kafka --topic new-topic

# トピックの削除
kafka-topics.sh --delete --zookeeper localhost:2181/kafka --topic new-topic
```

## TopicCommand

まず `kafka-topics.sh` の中身ですが、中身は以下の1行のみです。

```sh
# kafka-topics.sh
exec $(dirname $0)/kafka-run-class.sh kafka.admin.TopicCommand "$@"
```

Kafkaの管理ツールは `kafka-run-class.sh` を経由して、コンパイルされたクラスを実行します。
コード上でのクラスの実装は、 [`TopicCommand.scala`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala) にあります。

Kafkaのトピックの情報はZookeeperに保存されており、`kafka-topics.sh` もKafkaブローカーではなくZookeeperにアクセスします。

## トピックの一覧表示

Kafkaのトピック情報は、Zookeeper上の `${prefix}/brokers/topics/${topic}` に保存されてます。
`${prefix}/brokers/topics` 以下のノードを取得することでトピック一覧を取得できます。
TopicCommandでトピック一覧の取得は以下の部分でしてます。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L85
val allTopics = zkUtils.getAllTopics().sorted
```

`ZkUtils` はZookeeper上のKafkaの情報にアクセするためのユーティリティクラスです。
[`ZkUtils.getAllTopics()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/utils/ZkUtils.scala#L911-L917) の実装は次のようになってます。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/utils/ZkUtils.scala#L911-L917
def getAllTopics(): Seq[String] = {
  val topics = getChildrenParentMayNotExist(BrokerTopicsPath)
  if(topics == null)
    Seq.empty[String]
  else
    topics
}
```

`BrokerTopicsPath`は `${prefix}/brokers/topics` を指します。
[`ZkUtils.getChildrenParentMayNotExist()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/utils/ZkUtils.scala#L709-L715) はあるパス以下のノードのを取得します

## トピックの作成

トピックの作成には、トピック名の他にパーティション数とレプリカ数を指定します。
また `--replica-assignment` オプションで、レプリカをどのブローカーに割り当てるかを指定できます。
指定しないとクライアント側が割り当てを計算します。

コード的にはこの辺です。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L101-L111
if (opts.options.has(opts.replicaAssignmentOpt)) {
  val assignment = parseReplicaAssignment(opts.options.valueOf(opts.replicaAssignmentOpt))
  AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK(zkUtils, topic, assignment, configs, update = false)
} else {
  CommandLineUtils.checkRequiredArgs(opts.parser, opts.options, opts.partitionsOpt, opts.replicationFactorOpt)
  val partitions = opts.options.valueOf(opts.partitionsOpt).intValue
  val replicas = opts.options.valueOf(opts.replicationFactorOpt).intValue
  val rackAwareMode = if (opts.options.has(opts.disableRackAware)) RackAwareMode.Disabled
  else RackAwareMode.Enforced
  AdminUtils.createTopic(zkUtils, topic, partitions, replicas, configs, rackAwareMode)
}
```

`--replica-assignment`が与えられてるなら、その値をパースして
[`AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L504-L519)に渡します。
そうでないときは[`AdminUtils.createTopic()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L455-L464)を呼び出してますが、
内部でレプリカの割り当てを計算して `AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK()` に渡します。

### レプリカを手動で割り当てる時

上述のように、レプリカの割り当て情報をパースして、`AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK()`を呼び出します。
`AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK()`の実装は以下のようになってます。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L504-L519
def createOrUpdateTopicPartitionAssignmentPathInZK(zkUtils: ZkUtils,
                                                   topic: String,
                                                   partitionReplicaAssignment: Map[Int, Seq[Int]],
                                                   config: Properties = new Properties,
                                                   update: Boolean = false) {
  validateCreateOrUpdateTopic(zkUtils, topic, partitionReplicaAssignment, config, update)

  // Configs only matter if a topic is being created. Changing configs via AlterTopic is not supported
  if (!update) {
    // write out the config if there is any, this isn't transactional with the partition assignments
    writeEntityConfig(zkUtils, getEntityConfigPath(ConfigType.Topic, topic), config)
  }

  // create the partition assignment
  writeTopicPartitionAssignment(zkUtils, topic, partitionReplicaAssignment, update)
}
```

トピック更新時は `update=false` となり、[`writeEntityConfig()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L631-L634) を呼び出します。
Kafkaではトピックごとの設定をZookeeper上の `${prefix}/config/topics/${topic}` に記録します。
`writeEntityConfig()` は上記の場所にトピックの設定を記録するノードを作成します。
たとえばあるトピックに `flush.message` が設定されていると、以下のようなJSONで記録されます。

```json
{"version":1,"config":{"flush.messages":"1"}}
```

[`writeTopicPartitionAssignment()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L521-L538) は `${prefix}/brokers/topics/${topic}` にパーティションの割り当て情報を記録します。
たとえばパーティション0をブローカー0,1に、パーティション1をブローカー1,2に割り当てる場合、以下のようなJSONが記録されます。

```json
{"version":1,"partitions":{"0":[0,1],"1":[1,2]}}
```

### レプリカを自動で割り当てる時

レプリカを自動で割り当ててトピックを作成する、[`AdminUtils.createTopic()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L455-L464) の中身は以下のようになってます。


```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L461-L463
val brokerMetadatas = getBrokerMetadatas(zkUtils, rackAwareMode)
val replicaAssignment = AdminUtils.assignReplicasToBrokers(brokerMetadatas, partitions, replicationFactor)
AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK(zkUtils, topic, replicaAssignment, topicConfig)
```

まず [`getBrokerMetadatas()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L437-L453) でブローカーのラック情報を取得します。
そして [`AdminUtils.assignReplicasToBrokers()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L128) でレプリカの割り当てを計算して、
その結果を`AdminUtils.createOrUpdateTopicPartitionAssignmentPathInZK()`に渡します。

`AdminUtils.assignReplicasToBrokers()` は以下の3つのゴールを達成するように割り当てを計算します。

1. レプリカはブローカー間で偏りが無いこと
2. 同パーティションのレプリカはブローカー間で分散されること
3. ブローカーがラック情報を持つなら、ラック間でも分散されること

詳しいアルゴリズムは `AdminUtils.assignReplicasToBrokers()` のコメントに記述されてます。

## トピックの削除

Kafkaクラスタ内でのトピックの削除は、直接データを消しに行くのではなく、Zookeeperに削除リクエストのためのノードを作成します。
`${prefix}/admin/delete_topic/${topic}`にノードを作ると、ラスタ内のコントローラノードが削除処理を開始し、各ブローカーやZookeeper上からトピックの情報を削除します。
トピックの削除が完了すると、Zookeeper上からこのノードが削除されます。

具体的な削除リクエストを作成する処理は以下の部分のみです。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L188
zkUtils.createPersistentPath(getDeleteTopicPath(topic))
```

## トピックの詳細表示

`--describe` サブコマンドは、指定したトピックに対する以下の情報を取得します

- トピック
    - パーティション数
    - レプリカ数
    - トピックの設定
    - 削除予定か否か
- パーティション
    - レプリカの割り当て
    - リーダー
    - in-syncレプリカ

```console
$ kafka-topics.sh --zookeeper localhost:2181/kafka --create \
    --topic my-topic --partitions 2 --replication-factor 2 --config flush.messages=1
Created topic "my-topic".

$ kafka-topics.sh --zookeeper localhost:2181/kafka --describe --topic my-topic
Topic:my-topic  PartitionCount:2        ReplicationFactor:2     Configs:flush.messages=1
        Topic: my-topic Partition: 0    Leader: 0       Replicas: 0,1   Isr: 0,1
        Topic: my-topic Partition: 1    Leader: 1       Replicas: 1,0   Isr: 1,0
```

以下の3つのオプションは、特定のトピック、パーティションのみを表示できます。

- `--topics-with-overrides`: トピックの設定があるトピック名のみ表示
- `--under-replicated-partitions`: レプリカ中のパーティションのみ表示
- `--unavailable-partitions`: リーダーがいないパーティションのみ表示

これらの情報は全てZookeeper上から取得できます。
`${prefix}/brokers/topics/${topic}`には、レプリカの割り当てが記録されてます。
またこの情報から、トピックのパーティション数、レプリカ数も求まります。

```json
{"version":1,"partitions":{"1":[1,0],"0":[0,1]}}
```

`${prefix}/config/topics/${topic}` には、トピックの設定が記録されてます。

```json
{"version":1,"config":{"flush.messages":"1"}}
```

`${prefix}/brokers/topics/${topic}/partitions/${partition}/state` には、リーダーおよびin-syncレプリカが記録されてます。

```json
{"controller_epoch":2,"leader":0,"version":1,"leader_epoch":0,"isr":[0,1]}
```

describeの表示処理は、[`TopicCommand.describeTopics()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L203) に記述されてます。
まず、トピックの一覧（`--topic`オプションで指定したトピック、または全て）と、現在クラスタ内に存在するブローカーのリスト（`${prefix}/brokers/ids`以下）を取得します。
ブローカーのリストは、後にクラスタ内でリーダーが存在しているかをチェックするのに使います。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L204
val topics = getTopics(zkUtils, opts)
// ...
val liveBrokers = zkUtils.getAllBrokersInCluster().map(_.id).toSet
```

各トピックに対して、トピックの設定とレプリカの割り当てを取得して、必要な情報を抜き出します。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L217-L225
val configs = AdminUtils.fetchEntityConfig(zkUtils, ConfigType.Topic, topic).asScala
if (!reportOverriddenConfigs || configs.nonEmpty) {
  val numPartitions = topicPartitionAssignment.size
  val replicationFactor = topicPartitionAssignment.head._2.size
  val configsAsString = configs.map { case (k, v) => s"$k=$v" }.mkString(",")
  val markedForDeletionString = if (markedForDeletion) "\tMarkedForDeletion:true" else ""
  println("Topic:%s\tPartitionCount:%d\tReplicationFactor:%d\tConfigs:%s%s"
    .format(topic, numPartitions, replicationFactor, configsAsString, markedForDeletionString))
}
```

 [`AdminUtils.fetchEntityConfig()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminUtils.scala#L640-L658) で `${prefix}/config/topics/${topic}` からトピックの設定を取得します。
`--topic-with-overrides`が付与されてかつ、設定が空の場合トピックは表示しません。
パーティション数、レプリカ数はレプリカの割り当てから求めます。
また `${prefix}/admin/delete_topic/${topic}` の存在を確認して、削除予定ならそれも表示します。

パーティションの情報に関しては、in-syncレプリカとリーダーを `${prefix}/brokers/topics/${topic}/partitions/${partition}/state` から取得します。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/TopicCommand.scala#L229-L244
val inSyncReplicas = zkUtils.getInSyncReplicasForPartition(topic, partitionId)
val leader = zkUtils.getLeaderForPartition(topic, partitionId)
if ((!reportUnderReplicatedPartitions && !reportUnavailablePartitions) ||
    (reportUnderReplicatedPartitions && inSyncReplicas.size < assignedReplicas.size) ||
    (reportUnavailablePartitions && (leader.isEmpty || !liveBrokers.contains(leader.get)))) {

  val markedForDeletionString =
    if (markedForDeletion && !describeConfigs) "\tMarkedForDeletion: true" else ""
  print("\tTopic: " + topic)
  print("\tPartition: " + partitionId)
  print("\tLeader: " + (if(leader.isDefined) leader.get else "none"))
  print("\tReplicas: " + assignedReplicas.mkString(","))
  print("\tIsr: " + inSyncReplicas.mkString(","))
  print(markedForDeletionString)
  println()
}
```

in-syncレプリカとリーダーは、それぞれ
[`ZkUtils.getInSyncReplicasForPartition()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/utils/ZkUtils.scala#L373-L383) と
[`ZkUtils.getLeaderForPartition()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/utils/ZkUtils.scala#L339-L343) で取得できます。
`--under-replicated-partitions` オプションおよび `--unavailable-partitions` オプションが付与されてないときは、パーティションを表示します。
`--under-replicated-partitions` オプションが付与されてかつin-syncレプリカ数がレプリカ数より小さいなら、レプリカ中のパーティションを表示します。
`--unavailable-partitions` オプションが付与されてかつリーダーが空またはクラスタ内に存在しないなら、パーティションを表示します。

## まとめ

この記事では、`kafka-topics.sh` 機能のうち、トピックの一覧表示、作成、削除、詳細表示する機能を、コードベースで読み解いてゆきました。
分散システムの特性上KafkaはZookeeperにも多くのデータを残しているので、トラブル時にZookeeperを見ると障害対応の手がかりになります。

この記事ではZookeeperを利用したトピックの操作を紹介しましたが、
経由の実際Kafka 0.11.0.0から、トピックの作成と削除に関するAPIが追加されました
（[CreateTopics API](https://kafka.apache.org/protocol#The_Messages_CreateTopics)、[DeleteTopics API](https://kafka.apache.org/protocol#The_Messages_DeleteTopics)）。
今後もクライアント側はZookeeperへ依存しなくても、Kafkaのトピックの操作やその他の管理ができるようになるかも知れません。
