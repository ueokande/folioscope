---
title: Kafkaの管理ツールを読む - kafka-broker-api-versions.sh編
date: 2017-12-13 21:00 JST
tags: scala, kafka
---

この記事は [Distributed computing Advent Calendar 2017](https://qiita.com/advent-calendar/2017/distributed-computing) の13日目の記事です。

![Apache Kafka Logo](kafka.png)

Kafkaのブローカー間、あるいはブローカーとクライアント間の通信は、TCP経由のバイナリプロトコルです。
それぞれの通信はAPIとして定義されており、どういうフォーマットのリクエスト・レスポンスなのかが定められています。

APIにはバージョンがあります。
ブローカーがサポートするAPIのバージョンを取得するには、Kafkaに標準に同梱されている `kafka-broker-api-versions.sh` が利用できます。
`kafka-broker-api-versions.sh ` はクラスタ内に存在するブローカーのリストと、それぞれのブローカーがサポートするAPIバージョンを取得します。

```console
$ kafka-broker-api-versions.sh --bootstrap-server kafka-1.myhost:9092
kafka-1.myhost:9092 (id: 0 rack: null) -> (
        Produce(0): 0 to 5 [usable: 3],
        Fetch(1): 0 to 6 [usable: 5],
        Offsets(2): 0 to 2 [usable: 2],
        Metadata(3): 0 to 5 [usable: 4],
        LeaderAndIsr(4): 0 to 1 [usable: 0],
        StopReplica(5): 0 [usable: 0],
        UpdateMetadata(6): 0 to 4 [usable: 3],
        ControlledShutdown(7): 0 to 1 [usable: 1],
        OffsetCommit(8): 0 to 3 [usable: 3],
        OffsetFetch(9): 0 to 3 [usable: 3],
        FindCoordinator(10): 0 to 1 [usable: 1],
        JoinGroup(11): 0 to 2 [usable: 2],
        Heartbeat(12): 0 to 1 [usable: 1],
        LeaveGroup(13): 0 to 1 [usable: 1],
        SyncGroup(14): 0 to 1 [usable: 1],
        DescribeGroups(15): 0 to 1 [usable: 1],
        ListGroups(16): 0 to 1 [usable: 1],
        SaslHandshake(17): 0 to 1 [usable: 0],
        ApiVersions(18): 0 to 1 [usable: 1],
        CreateTopics(19): 0 to 2 [usable: 2],
        DeleteTopics(20): 0 to 1 [usable: 1],
        DeleteRecords(21): 0 [usable: 0],
        InitProducerId(22): 0 [usable: 0],
        OffsetForLeaderEpoch(23): 0 [usable: 0],
        AddPartitionsToTxn(24): 0 [usable: 0],
        AddOffsetsToTxn(25): 0 [usable: 0],
        EndTxn(26): 0 [usable: 0],
        WriteTxnMarkers(27): 0 [usable: 0],
        TxnOffsetCommit(28): 0 [usable: 0],
        DescribeAcls(29): 0 [usable: 0],
        CreateAcls(30): 0 [usable: 0],
        DeleteAcls(31): 0 [usable: 0],
        DescribeConfigs(32): 0 [usable: 0],
        AlterConfigs(33): 0 [usable: 0],
        UNKNOWN(34): 0,
        UNKNOWN(35): 0,
        UNKNOWN(36): 0,
        UNKNOWN(37): 0
)

```

たとえば `Produce(0): 0 to 5 [usable: 3]` は、ブローカーがProduce APIのバージョン0から5までをサポートしていることを意味し、
`usable` は現在のクライアントライブラリで利用可能なバージョンを指します。
カッコ内の数字は API key と呼ばれるもので、各APIを識別する番号です。

この記事では、`kafka-broker-api-versions.sh` を読んでいきたいと思います。

## BrokerApiVersionsCommand

`kafka-broker-api-versions.sh` の実装は
[`BrokerApiVersionsCommand.scala`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/BrokerApiVersionsCommand.scala) に実装があります。
このファイルは100行にも満たない小さなクラスですが、重要な部分は以下のコードのみです。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/BrokerApiVersionsCommand.scala#L41-L50
val adminClient = createAdminClient(opts)
adminClient.awaitBrokers()
val brokerMap = adminClient.listAllBrokerVersionInfo()
brokerMap.foreach { case (broker, versionInfoOrError) =>
  versionInfoOrError match {
    case Success(v) => out.print(s"${broker} -> ${v.toString(true)}\n")
    case Failure(v) => out.print(s"${broker} -> ERROR: ${v}\n")
  }
}
adminClient.close()
```

まず `AdminClient.awaitBrokers()` を呼び出して、クラスタ内にブローカーが現れるまで待ちます。
クラスタ内にブローカーが見つかると、どれか1つのブローカーに対して、クラスタに存在する全てのブローカーを問い合わせます。
その結果から、存在する全ブローカーに対してサポートするAPIのバージョンを問い合わせて、その結果を表示します。

## ブローカーを見つける

[`AdminClient.awaitBrokers()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L151-L158) はクラスタ内にブローカーが現れるまで待ちます。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L151-L158
def awaitBrokers() {
  var nodes = List[Node]()
  do {
    nodes = findAllBrokers()
    if (nodes.isEmpty)
      Thread.sleep(50)
  } while (nodes.isEmpty)
}
```

[`AdminClient.findAllBrokers()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L160) は、クラスタ内の全てのブローカーを探します。
Kafkaのクライアントを利用する時、ブートストラップサーバーを指定します。
しかし分散システムなので、常に全てのノードが生きている保証はありません。
`findAllBrokers()` はブートストラップのブローカーどれか1つに、現在クラスタ内に存在するブローカーを問い合わせます。

`AdminClient.findAllBrokers()` の実装は以下のようになってます。
[`AdminClient.sendAnyNode()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L93-L105)  は1番目に見つかったブローカーにリクエストを送ります。
全てのブローカーにリクエストを送れないと例外を投げます。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L160-L167
def findAllBrokers(): List[Node] = {
  val request = MetadataRequest.Builder.allTopics()
  val response = sendAnyNode(ApiKeys.METADATA, request).asInstanceOf[MetadataResponse]
  val errors = response.errors
  if (!errors.isEmpty)
    debug(s"Metadata request contained errors: $errors")
  response.cluster.nodes.asScala.toList
}
```

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L93-L105
private def sendAnyNode(api: ApiKeys, request: AbstractRequest.Builder[_ <: AbstractRequest]): AbstractResponse = {
  bootstrapBrokers.foreach { broker =>
    try {
      return send(broker, api, request)
    } catch {
      case e: AuthenticationException =>
        throw e
      case e: Exception =>
        debug(s"Request $api failed against node $broker", e)
    }
  }
  throw new RuntimeException(s"Request $api failed on brokers $bootstrapBrokers")
}
```

クラスタ内に存在するブローカーを問い合わせるのに、 [Metadata API](https://kafka.apache.org/protocol#The_Messages_Metadata) を使用します。
Metadata API は、クラスタ内のトピックやパーティション、リーダー情報やクラスタ情報を取得できるAPIで、任意のノードに対し利用できるAPIでもあります。

## APIバージョンを取得する

ここまでで、クラスタ内に存在するブローカーが取得できました。
あとはそれぞれのブローカーに対して、APIバージョンを問い合わせるだけです。
[`AdminClient.listAllBrokerVersionInfo()`](https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L207-L210) は、
クラスタ内のブローカーのリストを取得し、それぞれに対しAPIバージョンを取得します。

```scala
// https://github.com/apache/kafka/blob/1.0.0/core/src/main/scala/kafka/admin/AdminClient.scala#L207-L210
def listAllBrokerVersionInfo(): Map[Node, Try[NodeApiVersions]] =
  findAllBrokers.map { broker =>
    broker -> Try[NodeApiVersions](new NodeApiVersions(getApiVersions(broker).asJava))
  }.toMap
```

APIバージョンを取得するには、対象のブローカーに [`ApiVersions API`](https://kafka.apache.org/protocol#The_Messages_ApiVersions) を利用します。
レスポンスに各APIのサポートしてるAPIバージョンが含まれます。

```scala
// https://github.com/apache/kafka/blob/trunk/core/src/main/scala/kafka/admin/AdminClient.scala#L142-L146
def getApiVersions(node: Node): List[ApiVersion] = {
  val response = send(node, ApiKeys.API_VERSIONS, new ApiVersionsRequest.Builder()).asInstanceOf[ApiVersionsResponse]
  response.error.maybeThrow()
  response.apiVersions.asScala.toList
}
```

## まとめ

ここまでの処理をまとめると、次のようなステップでクラスタ内に存在するブローカーの、サポートするAPIバージョンを取得します。

1. クラスタにブローカーが現れるまで待つ
2. ブローカーが現れると、どれかのノードに Metadata API を利用して、クラスタ内のブローカーリストを取得する
3. ブローカーリストの各ブローカーにたいし ApiVersions API を利用してサポートするAPIのバージョンを取得する
4. 求まったブローカーリストとそれぞれのブローカーのサポートするAPIのバージョンを表示する

Kafkaのバイナリプロトコルについては、[Kafka protocol guide](https://kafka.apache.org/protocol) にあります。
興味があれば読んでみてはいかがでしょうか。
