---
title: MacのVimを強化する
date: 2012-09-16T11:58:51+09:00
tags: [Vim, Mac]
---

MacのVimはコンパイル時に幾つかの機能が制限されています．例えば，<span style="font-family:monospace">conceal</span>という文字を隠す機能がありますが，デフォルトでオフとなっています．この機能を使用するには，コンパイル時に指定する必要があります．

現在使っているVimの機能を確認するには，Vimの起動時に<span style="font-family:monospace">--version</span>オプションを指定します．

```
$ vim --version
```

<span style="font-family:monospace">+Unbabo</span>と表示されれば機能が使用でき，<span style="font-family:monospace">-Unbabo</span>と表示されれば使用できません．これらの制限されている機能を，MacPortsで再コンパイルして使えるようにしてみます．

MacPortsで利用可能なコンパイルオプションを確認するには，<span style="font-family:monospace">variants</span>オプションを指定します．

```
$ port variants vim
```

<span style="font-family:monospace">conceal</span>の機能を使いたい場合は<span style="font-family:monospace">huge</span>オプションを指定します．

```
$ sudo port install vim +huge
```

インストールが終了したらオプションを確認してみましょう

```
$ /opt/local/bin/vim --version
```

あとはお好みでパスを通してください．

