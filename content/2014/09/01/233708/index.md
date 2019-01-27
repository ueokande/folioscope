---
title: NATやGatewayやDHCP以下のマシンに外出先からでもアクセス
date: 2014-09-01T23:37:08+09:00
tags: [Linux]
---

[{{<img src="http://farm4.staticflickr.com/3178/2997336346_8025bc4b8c.jpg" alt="">}}](http://www.flickr.com/photos/10473890@N00/2997336346)  
[photo by Listen Missy\!](http://www.flickr.com/photos/10473890@N00/2997336346)

MicroServerが届いたのでサーバ周りの整理をしています。
外部からもアクセスしたいのですが、もちろんうちの学校にはFirewallがあります。
よくあるサーバが立てにくい環境でも外部からサーバにアクセスできるよう、
自分のVPSにSSHでトンネルを掘ってアクセスできるようにします。
ちょうどハブ・スポーク構造のようなものです。SSHを使うので安全で、VPNのようにお行儀の悪いパケットが流れません。
ここで、外部に公開されているサーバをHUBサーバ、GW以下のサーバをSPOKEサーバと呼ぶことにしましょう。

# HUBサーバ側の設定

まずセキュリティの関係から、コネクションを張るためのユーザを新たに作成します。
ここでは`hub-spoke`を作成します。
そしてログインパスワードを無効にし、ログインシェルを`/bin/cat`とします。

```sh
root@hub# adduser hub-spoke
root@hub# vipw -s   # パスワードを無効(x)に設定
root@hub# vipw      # ログインシェルを/bin/catに
```

次にSSHの秘密鍵を**パスフレーズ無し**で作成し、公開鍵を`hub-spoke`ユーザの`authorized_keys`に埋め込みます。

```
root@hub# ssh-keygen -f hub_key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):  空Enter
Enter same passphrase again:  空Enter
```

```
root@hub# cat hub_key.pub >>~hub-spoke/authorized_keys
```

これで万が一鍵が漏れても、悪さをされる心配はありません。

# SPOKEサーバ側の設定

次にNAT/GW以下のサーバにデーモンとしてSSHを走らせます。
ここではsystemdへのサービスに登録します。
まず `/usr/lib/systemd/system/hub-spoke.service` というファイルを作り、
次の設定を書き込みます。

```sh
[Unit]
Description=Hub-spoke daemon for the spoke side
After=network.target

[Service]
EnvironmentFile=/etc/sysconfig/hub-spoke
ExecStart=/usr/bin/ssh -o $ServerAliveIntervalOption -N -R $RemoteForward -p $Port -l $User -i $IdentifyFile $Host
KillMode=process
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

このファイルの`EnvironmentFile`で指定されているファイル `/etc/sysconfig/hub-spoke` に、
SPOKEサーバごとの設定を書き込みます。

```sh
# Server Alive Interval
ServerAliveIntervalOption= 'ServerAliveInterval=30'

# HUB側の10000ポートに、SPOKE側の22ポートをバインド
RemoteForward= 10000:127.0.0.1:22

# HUB側のSSHポート
Port= 22
# HUB側のSSHユーザ
User= 'hub-spoke'
# SSHの秘密
IdentifyFile= '/etc/hub-spoke/hub_key'
# HUBサーバのホスト
Host= 'hub.example.com'
```

適宜自分のサーバの設定（特にSSHのポート番号）に合わせて書き換えましょう．

最後に先ほど作成した秘密鍵をSPOKE側の`/etc/hub-spoke/hub_key`に置いて、パーティションを600にしておきます．

```sh
root@spoke# chmod 600 /etc/hub-spoke/hub_key
```

# SPOKE側のサービスの起動

まずknown\_hostsに登録して自動ログインできるように、rootでHUBサーバにログインします．
ログインシェルがcatになっているので、ログイン後はCtrl\-Cでログアウトします。

```sh
root@spoke# ssh -i/etc/hub-spoke/hub_key -lhub-spoke -p22 hub.example.com
```

そしてサービスを起動してみます。

```sh
root@spoke# systemctl start hub-spoke.service
```

次のコマンドでサービスが起動できたか、あるいは発生したエラーのチェックができます。

```sh
root@spoke# systemctl status hub-spoke.service
```

エラーがなかったら、HUB側で `localhost:10000`にsshしてみてください。
SPOKEに接続できれば設定成功です。

```
user@hub> ssh -p10000 localhost
Password:
user@spoke>
```

最後にサービスを登録して完了です。

```sh
root@spoke# systemctl enable hub-spoke.service
```

これでコネクションが切れたり、再起動後も自動で接続するはずです。

# 接続中のマシンを見る

HUB側でどのマシンが接続されているかリストできると便利なのでスクリプトを作りました。localhostのポートを`nc`で叩いてコネクションを確認します。

```sh
#/bin/sh

check_port () {
  port=$1
  hostname=$2

  if nc -v -z -w 3 localhost $port >/dev/null 2>&1; then
    echo "$port : $hostname is alive"
  else
    echo "$port : $hostname is dead"
  fi
}

check_port 10000 host1
check_port 10001 host2
check_port 10002 host3
```

