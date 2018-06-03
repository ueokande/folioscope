---
title: Linuxのユーザー管理をetcd上でする
date: 2018-06-03 21:00 JST
---

週末の自由研究で、Linuxのユーザー管理をetcd上でするサービスを書いてみました。

複数のマシン間でユーザー情報を管理するサービスといえば、LDAPが有名所です。
しかしLDAPは重装備すぎるので、もっとlightweightなサービスができないかと考えてみました。
そこでPoCですが、etcdをバックエンドにユーザー管理をしてみました。

![github][ueokande/etcd-passwd]

## NSSサービスを書く

Linuxのユーザー情報を、`/etc/passwd`以外を参照するには、Name Service Switch (NSS)を設定します。
NSSとは、ユーザーやグループ、ホスト名を参照する時の参照データベースを切り替える仕組みです。
その設定は `/etc/nsswitch.conf` にあります。

たとえば以下のような設定があります。

```
# /etc/nsswitch.conf
passwd: files
group:  files
...
```

これは、passwd（ユーザー情報）とgroupをfilesサービスを使って参照するということである。
passwdのfilesサービスは`/etc/passwd`を参照し、gropupのfilesサービスは`/etc/group`を参照サービスです。
LDAPを設定するときは、以下のように`ldap`サービスを使うよう設定します。

```
# /etc/nsswitch.conf
passwd: files ldap
group:  files ldap
...
```

今回作成したサービスは`etcd`という名前にしたので、`/etc/nsswitch.conf` に`etcd` という名前を追加する。を追加します。

```
# /etc/nsswitch.conf
passwd: files etcd
...
```

NSSを使って実際のエントリを取得する手順を、`getpwuid_r()`関数を例に説明します。
`getpwuid_r()`関数は、UIDを元にユーザー情報を取得する関数です。
ユーザーが`getpwent_r()`を呼び出すと、`/etc/nsswitch.conf` に列挙されたそれぞれのサービスのからエントリを取得します。
`getpwent_r()`に対応する実装は、`/usr/lib/libnss_<service>.so.2` ファイルに記述の `_nss_<service>_getpwuid_r()` 関数に記述されてます。
以上の命名規則で、これで `/etc/nsswitch.conf` に記述されたサービス名から、それぞれの実装に到達することができました。

ユーザー名を参照するときに利用される関数は以下のとおりです。

```c
void setpwent(void);
void endpwent(void);
int getpwent_r(struct passwd *p, char *buf, size_t len, int *errnop);
int getpwnam_r(const char *name, struct passwd *p, char *buf, size_t len, int *errnop);
int getpwuid_r(uid_t uid, struct passwd *p, char *buf, size_t len, int *errnop);
```

`setpwent()`, `endpwent()`, は`getpwent_r()`を呼び出すためのpasswdデータベースの接続、終了処理です。
`getpwent_r()` は1行ずつエントリーを読み込みます。
`getpwnam_r()`、`getpwuid_r()`はそれぞれ、ユーザ名、ユーザIDでユーザーエントリーを参照します。
`getent passwd` で前者の3つの関数が、`getent passwd <name>` で `getpwent_r()` が、`getent passwd <uid>` で `getpwuid_r()` を呼び出します。

`etcd` というNSSサービスのそれぞれの関数の中身を実装するには、`_nss_<service>_<function name>`とう名前で関数を実装します。
今回実装した `etcd` サービスに対応する、5つの関数の定義は以下のとおりとなります。

```c
extern enum nss_status _nss_etcd_setpwent(void);
extern enum nss_status _nss_etcd_endpwent(void);
extern enum nss_status _nss_etcd_getpwent_r(struct passwd *p, char *buf, size_t len, int *errnop);
extern enum nss_status _nss_etcd_getpwnam_r(const char *name, struct passwd *, char *buf, size_t len, int *errnop);
extern enum nss_status _nss_etcd_getpwuid_r(uid_t uid, struct passwd *, char *buf, size_t len, int *errnop);
```

## NSSサービスの実装 : `getpwnam_r`の実装例

`getpwnam_r()` の実装例を見てゆきます。
まず、`_nss_etcd_getpwnam_r()` という名前の関数を宣言して `extern` します。
これで外部から、`_nss_etcd_getpwnam_r` という名前で関数を参照できます。

```c
// user.h
extern enum nss_status _nss_etcd_getpwnam_r(const char *name, struct passwd *, char *buf, size_t len, int *errnop);
```

そして実装を`.c` ファイルに記述します。

```c
// user.c
enum nss_status _nss_etcd_getpwuid_r(uid_t uid, struct passwd *p, char *buf, size_t len, int *errnop) {
	return go_getpwuid(uid, p, buf, len, errnop);
}
```

生のCは辛いので、殆どの実装をgolangで行い、Cの関数とのやり取りにcgoを使ってビルドします。
`_nss_etcd_getpwnam_r()`が呼び出してる`go_getpwuid`の実装はGoにあります。

```go
// user.go

//export go_getpwuid
func go_getpwuid(uid UID, passwd *C.struct_passwd, buf *C.char, buflen C.size_t, errnop *C.int) nssStatus {
	p, err := impl.Getpwuid(uid)
	if err == ErrNotFound {
		return nssStatusNotfound
	} else if err != nil {
		return nssStatusUnavail
	}
	return setCPasswd(p, passwd, buf, buflen, errnop)
}
```

[`Getpwuid()`](https://github.com/ueokande/etcd-passwd/blob/5f555c9ac1d6139258f83fe7322369fbc3f41e1e/etcd.go#L112)関数は、`uid`に一致するユーザーをetcdから取得する関数です。
[`setCPasswd()`](https://github.com/ueokande/etcd-passwd/blob/5f555c9ac1d6139258f83fe7322369fbc3f41e1e/user.go#L40)は、GoのstructからCの`struct passwd`および、`char *` に展開するヘルパ関数です。
ここでは詳しくは説明しないので、興味のある人はGitHub上の実装を追ってください。

## インストールする

とりあえずのPoCで、参照するのはpasswd（グループは見ない）のみですが、ひとまず動かしてみます。
まずはプロジェクトを取得して、必要な依存パッケージをインストールします。

```console
$ go get github.com/ueokande/etcd-passwd
$ cd $GOPATH/src/github.com/ueokande/etcd-passwd
$ go get ./...
```

そしてプロジェクトをビルドして、システムにインストールします。すると`/usr/lib/libnss_etcd.so.2`にetcdサービスが作成されました。

```console
$ make build
$ sudo make install
```

そして `/etc/nsswitch.conf` を編集します。

```conf
# /etc/nsswitch.conf
passwd:         compat etcd
```

最後にetcdをローカルで起動します。

```console
$ etcd
```

## ユーザーの追加と参照

ユーザーを追加します。`cmd/etcdadduser` にユーザー追加のクライアントコマンドを用意してます。
以下のように使います。

```conf
$ go run cmd/etcdadduser/main.go -name peter -uid 10000 -gid 10000 -gecos 'Peter Rabbit'
```

するとetcd上にエントリがJSON形式で追加されます。

```console
$ ETCDCTL_API=3 etcdctl get --print-value-only  /etcd-sshd/users/10000
{"Name":"peter","Passwd":"!","UID":10000,"GID":10000,"Gecos":"Peter Rabbit","Dir":"/home/peter","Shell":"/bin/sh"}
```
ここまでの手順で、新たなユーザーが参照できるようになりました。
実際に追加したユーザーのエントリを参照してみます。

```console
# passwdのキャッシュを無効化
$ sudo nscd --invalidate=passwd

# getentでユーザー名を指定して取得
$ getent passwd peter
peter:!:10000:10000:Peter Rabbit:/home/peter:/bin/sh

# 追加したユーザーになる
$ sudo -u peter id
uid=10000(peter) gid=10000 groups=10000
```
## おわりに

以上で、GoによるNSSの実装方法でした。
現在ではまだユーザーデータベースしか参照しません。
グループのデータベースを参照するには、`setgrent()`, `getgrent()`, `endgrent()`, `getgrnam_r()`, `getgrgid_r()` を実装します。

このNSSサービスを実装するとき、NSSだけではなくcgoについても調べまくりました。
そのときに得られた知見については、また別の記事で紹介したいと思います。
