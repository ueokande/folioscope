---
title: これまでshだと信じていたものがbashだった
date: 2013-11-29T16:03:36+09:00
tags: [sh]
---

openSUSEやCentOSの場合

```
$ ls -la /bin/sh
lrwxrwxrwx 1 root root 4 Mar 25  2013 /bin/sh -> bash
```

shはbashのエイリアスだった．

Mac OS Xの場合

```
$ ls -la /bin/sh
-r-xr-xr-x 1 root wheel 1228304 Oct 23 13:59 /bin/sh
```

本物のsh\(Bourne Shell\)かと思いきや

```
$ /bin/sh --version
GNU bash, version 3.2.51(1)-release (x86_64-apple-darwin13)
Copyright (C) 2007 Free Software Foundation, Inc.
```

つまり多くのLinuxディストリビューションやMac OS Xでも，Bourne Shellはなくshはbashで置換されているのである．
これまで自分が書いていてシェルスクリプトはBourne Shellスクリプトだと信じて疑わなかったが，実はBashスクリプトであったのだ．

これまでshebangに

```sh
#!/bin/sh
```

と書いて，自分はB\-shを使っていたと錯覚していたが，bashのインタプリタで処理されていた．
そして中には，bashで拡張された文法も使用していたのであったが，bashで処理されるため，そのバグに気づかなかった．
つい先日公開した[ターミナルにサイン波を描くプログラム](https://gist.github.com/iBenza/7687234)にもbashの文法が含まれていたので，
あわててshebangのみを修正した．

ちょっと探してみると，shebangからshを呼び出しておきながら，B\-shには無い実装を使っている例がちらほら見当たる．
これからはshの文法にのっとった，生のB\-shスクリプトを書く努力をしようと思う．

