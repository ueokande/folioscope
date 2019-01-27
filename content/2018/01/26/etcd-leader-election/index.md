---
title: etcdでleader electionしようと思ったら難しかった話
date: 2018-01-26T22:00:00+09:00
tags:
---

あるクラスタ内に複数ノードがあり、そのうち高々1ノードのみがサービスを提供する仕組みを作りたいと思いました。
これはetcdを使うとかんたんに実装できるんじゃないかとおもい試してみました。

etcdにはcompare and swapのAPIがあり、キーの前の値や無い時のみにキーを更新できます。
それを使ってノード間でleader electionして、leaderになった後にサービスを起動する仕組みを考えました。
他の場所でもよくみる方法だったので、これを使えば実現できるんじゃないかと思い実装してみました。

- [https://github.com/coreos/etcd/issues/225](https://github.com/coreos/etcd/issues/225)
- [https://www.sandtable.com/etcd3-leader-election-using-python/](yhttps://www.sandtable.com/etcd3-leader-election-using-python/)

試しに次のようなシェルスクリプトを書いてみました。
結果から言うと、**これは正しく動きません**。

```sh
#!/bin/sh

ID=$(uuidgen)
LEADER_KEY="localhost:2379/v2/keys/master"
TTL=5
INTERVAL=1

i_am_leader() {
  echo "I am leader";
  while true; do
    body=$(curl -sSL -XPUT "${LEADER_KEY}?prevValue=${ID}&ttl=${TTL}&value=${ID}")
    [ $? != 0 ] && return
    
    errorCode=$(echo $body | jq -r .errorCode)
    if [ $errorCode != 'null' ]; then
      echo "something fail"
      exit 1
    fi

    # do something
    sleep $INTERVAL
  done
}

try_to_be_leader() {
  echo "wait for leader dying"
  while true; do
    body=$(curl -sSL -XPUT "${LEADER_KEY}?prevExist=false&ttl=${TTL}&value=${ID}")
    [ $? != 0 ] && return

    errorCode=$(echo $body | jq -r .errorCode)
    if [ $errorCode = 'null' ]; then
      i_am_leader
    fi

    sleep $INTERVAL
  done
}

try_to_be_leader
```

etcdを使ったleader electionでは、TTLを使ってleaderを表すkeyを作り、クライアントはTTL未満でそのノードを上書きし続けます。
しかしこの方法には問題があり、あるノードがleaderを獲得してから処理を始めるまでに（do somethingまでに）ノードがTTLの時間以上停止してしまうとetcdからkeyが消えます。
その間に他のノードがleaderになってしまい、結果として複数ノードが同時にdo somethingの部分を実行します。

TTLベースでlockを取ると上記のことは避けられないようで、別の箇所で回避する必要があります。
KubernetesやKafkaでは楽観的ロックを使って複数からのデータ更新を防いでます。
うーん分散システムは難しい。
