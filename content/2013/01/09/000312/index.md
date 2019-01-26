---
title: Firefoxでアプリケーションモードっぽく
date: 2013-01-09T00:03:12+09:00
tags: 
---

Google Chromeに<span style="font-family:monospace">--app</span>オプションを付けると，タイトルバーの無いブラウザが起動し，あたかもWebページがひとつのアプリケーションであるかのように見せます．これと同じ事をFirefoxでもやってみたいと思います．

まずFirefoxに<span style="font-family:monospace">-p</span>オプションを付け，プロファイルの管理画面を開きます．

```
firefox -p
```

そして適当なプロファイルを新たに作成し，そのプロファイルでFirefoxを起動します．Firefoxを開くと，上部に表示されているツールバーをすべて隠します．またFirefoxの設定の「タブ」にある「常にタブバーを表示する」のチェックを外します．これでFirefoxがすっきりしました． 

これで準備はOK．指定したURLをアプリケーションモードのように開くには，次のようなオプションを指定してFirefoxを起動します．

```
firefox -P<追加したプロファイル名> -new-instance <開きたいURL>
```

いちいちコマンドラインを入力するのが面倒な人は，<span style="font-family:monospace">alias</span>に登録しておくと便利です．

```
alias webapp="firefox -P<追加したプロファイル名> -new-instance"
```

