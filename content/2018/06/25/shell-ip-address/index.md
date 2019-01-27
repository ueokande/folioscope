---
title: シェルスクリプトでIPアドレスの計算
date: 2018-06-25T18:00:00+09:00
tags: [sh]
---

IPAMやDHCPサーバーを実装するとき、IPアドレスを機械的に生成するために、IPアドレスの計算をする事があります。
例えばIPAMがラックやデータセンターから機械的にIPアドレスを割り当てたり、DHCPサーバーが連番のIPアドレスを割り当てたりします。
この記事ではシェルスクリプトでIPアドレスを計算する方法を紹介します。

## IPアドレスと数値の変換

IPアドレスを計算する上で欠かせない操作が、IPアドレスと数値の相互変換です。
IPv4アドレスは長さ4のバイト列に過ぎませんが、通常は`192.168.0.1` のように人間の扱いやすい文字列で表現します。
一方IPアドレスを計算するには、IPアドレスをバイト列や32ビット数値などの、計算機で扱いやすい形に変換します。
IPアドレスを数値として扱えると、数値演算でIPアドレスを計算したりネットワークアドレスを求めやすくなります。

実はPythonは標準で、IPアドレスと数値の相互変換を簡単にできます。

```python
import ipaddress
ipaddress.ip_address('192.168.1.200') + 100
# => IPv4Address('192.168.2.44')
```

ではシェルスクリプトではどうするか。
IPアドレスを数値に変換する`ip4_to_int`関数と、数値からIPアドレスに変換する`int_to_ip4`関数を記述してゆきます。


`ip4_to_int` は `A.B.C.D` というIPv4アドレスを整数に変換します。

```sh
# converts IPv4 as "A.B.C.D" to integer
ip4_to_int() {
  IFS=. read -r i j k l <<EOF
$1
EOF
  echo $(( (i << 24) + (j << 16) + (k << 8) + l ))
}
```

`A.B.C.D`という文字列から、各オクテットを抽出して、変数`i`, `j`, `k`, `l`に格納します。
環境変数`IFS`を設定して、`read` 関数の区切り文字を指定します。
`i`, `j`, `k`, `l` に格納したら、それぞれビットシフトして加算することで、各オクテットから32ビット数値に変換します。
シェルでは `$(( ... ))`で囲むと、数値計算できます。


`int_to_ip4` はIPv4アドレスの整数から `A.B.C.D` という形の文字列に変換します。

```sh
# converts interger to IPv4 as "A.B.C.D"
int_to_ip4() {
  echo "$(( ($1 >> 24) % 256 )).$(( ($1 >> 16) % 256 )).$(( ($1 >> 8) % 256 )).$(( $1 % 256 ))"
}
```

こちらは、数値をビットシフトして、256の剰余を求めます。そして各オクテットの値を取得して、再び文字列に変換します。

使い方はこんな感じです。


```sh
ip4_to_int 192.168.0.1
# => 3232235521

int_to_ip4 3232235521
# => 192.168.0.1
```

## ネットワークアドレスを求める

この例だけでは退屈なので、ネットワークアドレスを取得してみます。
ネットワークアドレスは、IPアドレスとネットマスクの各ビットで論理和によって求まります。
論理和を計算するために `A.B.C.D` という文字列から一度整数に変換します。
次の例は、IPアドレス `172.16.10.20` とネットマスク `255.255.252.0` から、ネットワークアドレス`172.16.8.0` を求めます。
IPアドレスとネットマスクを`ip4_to_int` を使って一度数値に変換して、その論理和を再び `int_to_ip4` で人間が読みやすい形式に変換します。

```sh
ip=$(ip4_to_int 172.16.10.20)
netmask=$(ip4_to_int 255.255.252.0)
int_to_ip4 $((ip & netmask))
# => 172.16.8.0
```

ネットワークアドレスが求まれば、「ネットワークアドレス + 1」のアドレス（つまりはよくあるデフォルトゲートウェイ）を計算することもできます。

```sh
ip=$(ip4_to_int 172.16.10.20)
netmask=$(ip4_to_int 255.255.252.0)
int_to_ip4 $(((ip & netmask) + 1))
# => 172.16.8.1
```

## CIDRと組み合わせる

CIDR(Classless Inter-Domain Routing)とは、IPアドレスとネットマスクを `A.B.C.D/E` で表したものです。
CIDRも非常によく使う表現なので、CIDRを扱うためのユーティリティ関数があると便利です。
まずはCIDRをIPアドレス部とプレフィクスに分割する関数を定義します。

```sh
# returns the ip part of an CIDR
cidr_ip() {
  IFS=/ read -r ip _ <<EOF
$1
EOF
  echo $ip
}

# returns the prefix part of an CIDR
cidr_prefix() {
  IFS=/ read -r _ prefix <<EOF
$1
EOF
  echo $prefix
}
```

```sh
cidr_ip "172.16.0.10/22"
# => 172.16.0.10
cidr_prefix "172.16.0.10/22"
# => 22
```

CIDRのプレフィクスはそのままだと扱いにくいので、ネットマスクの数値に変換する関数も定義します。

```sh
# returns net mask in numberic from prefix size
netmask_of_prefix() {
  echo $((4294967295 ^ (1 << (32 - $1)) - 1))
}
```

```sh
netmask_of_prefix 8
# => 4278190080
```

ここまでの関数を組み合わせると、CIDRから「ネットワークアドレス + 1」のアドレスを計算する関数を定義できます。

```sh
# returns default gateway address (network address + 1) from CIDR
cidr_default_gw() {
  ip=$(ip4_to_int $(cidr_ip $1))
  prefix=$(cidr_prefix $1)
  netmask=$(netmask_of_prefix $prefix)
  gw=$((ip & netmask + 1))
  int_to_ip4 $gw
}
```

```sh
cidr_default_gw 192.168.10.1/24
# => 192.168.10.1
cidr_default_gw 192.168.10.1/16
# => 192.168.0.1
cidr_default_gw 172.17.18.19/20
# => 172.17.16.1
```

また「ブロードキャストアドレス - 1」のパターンのデフォルトゲートウェイも簡単に計算できます。

```sh
# returns default gateway address (broadcast address - 1) from CIDR
cidr_default_gw_2() {
  ip=$(ip4_to_int $(cidr_ip $1))
  prefix=$(cidr_prefix $1)
  netmask=$(netmask_of_prefix $prefix)
  broadcast=$(((4294967295 - netmask) | ip))
  int_to_ip4 $((broadcast - 1))
}

cidr_default_gw_2 192.168.10.1/24
# => 192.168.10.254
cidr_default_gw_2 192.168.10.1/16
# => 192.168.255.254
cidr_default_gw_2 172.17.18.19/20
# => 172.17.31.254
```

#a おわりに

シェルスクリプトでIPアドレスが計算できると、たとえばプロビジョニングスクリプトをシェルで記述して、IPアドレスの設定などを自動で行うなどができます。
今回のコードはパースエラーなどはチェックしてませんが、ユーザーからの入力をこれらの関数に渡す場合は、厳密にチェックすべきでしょう。
今回のコード例はGistに置いておきます。

- [https://gist.github.com/ueokande/05d3c03871048b7d996fa618d89d1a1b](https://gist.github.com/ueokande/05d3c03871048b7d996fa618d89d1a1b)
