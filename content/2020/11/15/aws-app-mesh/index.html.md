---
title: サービスメッシュとAWS App Meshに入門した
date: 2020-11-15T23:00:00+09:00
tags: [AWS, Envoy Proxy]
---

こんにちは、ご無沙汰しています。
2020年も終わろうとしていますが、この度サービスメッシュとAWS App Meshに入門しました。

## サービスメッシュ超入門

AWS App Meshは、AWS上のサービスでサービスメッシュを実現するためのAWSサービスです。
サービスメッシュやその背景については、Toriさんによる「サービスメッシュは本当に必要なのか、何を解決するのか」の講演が詳しいです（この講演にも最後の5分くらいでApp Meshが登場します）。

<iframe width="560" height="315" src="https://www.youtube.com/embed/ZwfdLAClzsc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


サービスメッシュは、サービス間の通信のリトライ処理、レートリミット、サーキットブレイカーなどの仕組みを、クライアントやサーバー側で制御するのではなく、プロキシサーバーで解決します。
[Envoy Proxy][]は、サービスメッシュのプロキシサーバーとして、広く利用されています。

Envoy Proxyへのリトライやレートリミットのポリシーの設定は静的ファイルでも設定できますが、 **xDS API** を使ってEnvoy Proxyの外で一括して管理できます。
この設定を管理（**コントロールプレーン**）とEnvoy Proxy本体（**データプレーン**）を分離する設計によって、Microservicesなど異なるチームで管理されているサービス間通信を、クライアント、サーバーのどちらにも手を入れずとも制御できるようになります。

{{< figure src="envoy_xds.png" title="Envoy ProxyとxDS" >}}

xDS APIプロトコルはオープンな仕様なので誰でも実装できます。
**AWS App Mesh**は、Envoyコントロールプレーンのマネージドサービスです。

## App Meshのコンセプト

AWS App Meshは、サービスメッシュを構成するためのいくつかのリソースがあります。
そのリソースはAWS上のリソースとして管理されます。
その構成に基づいてEnvoy Proxyに設定が適用されて、サービスメッシュを構成します。


{{< figure src="simple-app-with-mesh-diagram.png" title="AWS App Meshの構成 (AWS公式ドキュメントより)" >}}
[a]: https://docs.aws.amazon.com/app-mesh/latest/userguide/what-is-app-mesh.html


AWS App Meshの構成要素はいくつかあります。
その中で代表的な物をいくつか紹介します。

- **メッシュ**
メッシュとは、サービスメッシュ内のサービス間トラフィックの論理的な集合です。
メッシュ内には、仮想サービス、仮想ノード、仮想ルーターなどを定義してサービス間の通信を定義します。
- **仮想ノード**
仮想ノードとは同一のサービスをまとめたものです。
EKS上では通常、DeploymentリソースとServiceリソースに対応します。
- **仮想ルーター**
仮想ルーターは、リクエストの種類や重み付けによって送り先の仮想ノードを決定する、仮想的なロードバランサーです。
- **仮想サービス**
仮想サービスとは、仮想ノードから別のサービスに通信するための、サービスを抽象化したものです。
仮想サービスは仮想ノードまたは仮想ルーターによって提供されます。

これらの構成要素に対応する実体となるサービスが、Kubernetes上にデプロイされるわけではありません。
これらの設定は各コンテナにサイドカーとしてデプロイされるEnvoy Proxyの設定として適用されます。
たとえばサービスメッシュの管理者が、仮想ノードや仮想ルーターを追加したり設定を変更すると、その構成に応じた設定がEnvoy Proxyに反映されます。

## ネットワーク構成

App Mesh内にデプロイしたサービスは全てサイドカーにデプロイされているEnvoy Proxyを経由して通信します。
クライアント側はサイドカーのEnvoy Proxyを経由してリクエストを送信し、それを相手のサービスのEnvoy Proxyが受け取り、実際のサービスにリクエストを渡します。
この、クライアント、サーバー両方のEnvoy Proxyを経由することで、App Meshの複雑な構成や、リトライ処理、サーキットブレイカー、分散トレーシングなどを実現しています。

たとえば、あるサービスをカナリアリリースするために、v1サービス/v2サービスを、それぞれ90%/10%で重み付きロードバランシングする例を考えます。
素朴な構成で重み付きロードバランシングするときは、v1/v2サービスの前段にロードバランサーを配置すると思います。
App Meshの場合はロードバランサーを、クライアント側のEnvoy Proxyで実装されます。

{{< figure src="weighted_load_balancing.png" title="重み付きロードバランシングの例" >}}

## カスタムコントローラー

App MeshをKubernetes上にデプロイするときは、カスタムコントローラ ([appmesh-controller][]) を事前にデプロイする必要があります。
このカスタムコントローラの役割は主に2つです。

1. カスタムリソースからApp Meshリソースを作成
2. Envoyサイドカーの注入

### カスタムリソースからApp Meshリソースを作成

Kubernetes上でApp Meshを利用する場合は、AWSのApp Meshのリソースをそのまま作成・更新するのではなく、Kubernetes上にカスタムリソースを定義します。
App Mesh上の仮想ノード、仮想ルーターなどは、それぞれ`virtualrouter.appmesh.k8s.aws`や`virtualnode.appmesh.k8s.aws`などのカスタムリソースとして定義します。
サービスメッシュ管理者は、サービスメッシュの構成をKubernetesマニフェストとして定義します。

作られたリソースをカスタムコントローラがバリデーションなどをして、AWS上のリソースとして反映します。
そしてAWS上のリソースが作成、更新されると、Envoy ProxyはxDS API経由で設定を更新します。

### Envoy Proxyの注入

もう1つ重要なのが、デプロイされるPodに対してのEnvoy Proxyの注入です。

ユーザーが既存のサービスからApp Meshに移行するとき、既存のコードに手を入れる必要はありません。
`appmesh.k8s.aws/sidecarInjectorWebhook: enabled` ラベルが付けられているNamespaceにPodがデプロイされるとき、カスタムコントローラ自動でEnvoy Proxyをサイドカーとして追加します。
そのため既存のDeploymentは手を加えること無くApp Mesh上でも利用できます。

これはKubernetesの[Admission Container][admission-controller]という仕組みで動作します。
この記事では詳しく述べませんが、Admission Containerとはリソースが作成される前に、リソースの設定値を検証したり、中身を書き換えることができます。

さて、既存のコードに手を加えることなくApp Meshが利用できると書きました。
しかし上記のネットワーク構成で説明したとおり、クライアントは自身のサイドカーにデプロイされているEnvoy Proxyと通信します。
これを実現するために、カスタムコントローラはInitコンテナで、サービス起動前にPod内のネットワーク設定を書き換えます。
`iptables` を使って、Pod内の通信を全てEnvoy Proxyに転送するように設定します。

## トラブルシューティング

App Meshの背景にあるのはEnvoy Proxyとマネージドなコントロールプレーンです。
Envoy Proxyの動作が透けて見えるようになったら、App Meshも怖くありません。
ここでは自分が実際にApp Meshを触ってみたときの、トラブルシューティングのいくつかを紹介します。

### 構成がよくわからない

App Meshは既存のサービスを元に透過的にサービスメッシュを利用できる反面、構成がわからないとまともに運用はできません。
まずはApp Meshの構成を知るところから始めましょう。

手始めにデプロイしたPodの情報を見てみましょう。
自分が管理していないInitコンテナやサイドカーコンテナがデプロイされているはずです。

```console
$ kubectl describe pod my-service-a-xxxxxxxxxx-xxxxx
```

App Meshの構成情報は全て、はEnvoy Proxyの設定となって現れます。
つまりEnvoy Proxyの設定を見れば、現在のサービスメッシュの構成が全て分かります。
Envoy Proxyは9901ポートに、管理用サーバーが立っています。
それを手元にport-forwardすることで、現在の設定を確認することができます。

```console
$ kubectl port-forward my-service-a-xxxxxxxxxx-xxxxx 9901:9901
```

Webブラウザで `http://127.0.0.1:9901` で開くと、Envoy Proxyの現在の設定や統計情報が確認できます。

### Connection reset by peer

これはHTTP接続をしようとして、Envoy Proxyがコネクションをリセットした時に発生します。
この原因は、Envoy Proxyの設定と実際のサービスの設定が食い違っている時に表示されることが多いです。

App Mesh利用をしていない素のKubernetesでは、ポート名が間違っているとTCP接続すらできません。
一方でApp Meshを利用していると、一度全ての通信はサイドカーのEnvoy Proxyが受け取るため、TCP接続自体は確立できているのです。

接続先が正しいかどうかは、Envoy Proxyコンテナからの接続を試みてください。
Envoy Proxyコンテナからの通信は、クライアント側のEnvoy Proxyを経由せずに相手のPodに接続します。

```console
kubectl exec my-service-b-xxxxxxxxx-xxxxx -cenvoy -- curl -sS -I my-service-a:8000
```

### 404 Not Found

これもEnvoy Proxyの設定がうまくできてないときに発生します。
ステータスコード404を誰が返しているかは、レスポンスヘッダをみると分かります。
Envoy Proxyが返すレスポンスには、ヘッダーに `server: envoy` が乗っています。

また[アクセスログ][access-logs]を見ると、誰が404を返しているかも分かります。
クライアント側のEnvoy Proxyのみが404のログが現れているときは、たとえば仮想ノードのバックエンドが正しく設定できていないかもわかりません。

[Envoy Proxy]: https://www.envoyproxy.io/
[appmesh-controller]: https://github.com/aws/aws-app-mesh-controller-for-k8s
[admission-controller]: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/
[access-logs]: https://docs.aws.amazon.com/app-mesh/latest/userguide/observability.html#envoy-logs
