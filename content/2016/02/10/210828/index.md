---
title: 中学2年生のときに作ったスクリーンセーバー
date: 2016-02-10T21:08:28+09:00
tags: 
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2016/02/10/20160210210411.png" alt="f:id:ibenza:20160210210411p:plain" title="f:id:ibenza:20160210210411p:plain" class="hatena-fotolife" itemprop="image"></span>

GUIプログラミングを始めた人が作りたいもの、
そして中学2年生が見てワクワクするもの、
それは共通して映画「マトリックス」の緑の文字が画面上に覆い尽くされるアレです。
自分が中学2年生のとき、C\+\+とWin32APIを使ってGUIアプリケーションにハマっていて、
同時にマトリックスも大好きだったので、スクリーンセーバーを作りました。

![github][ueokande/matrix.scr]

ファイルのタイムスタンプを見ると、2006年8月30日でした。
いまから10年前ですが、お蔵入りにするのがもったいなかったので公開しました。
当時書いたコード、10年後の2016年になっても、コンパイルできて[バイナリ](https://github.com/ueokande/matrix.scr/releases)もそのまま実行できます。

## 背景

マシンは父親から譲り受けたFMVに、コンパイラはVisual C\+\+ 5\.0を使って、Win32APIの勉強に勤しんでいました。
そしてWin32APIの勉強は[猫でもわかるWindowsプログラミング](http://www.kumei.ne.jp/c_lang/)で進めてました。
その本にはスクリーンセーバーの雛形のサンプルも会ったので、それを元にマトリックスの文字を流しました。

## ビルド

現在は残念ながらVisual C\+\+のビルド環境が無いですが、[Appveyor上](https://ci.appveyor.com/project/ueokande/matrix-scr)でビルしてます。
便利な時代です。
当時はまだクラウドという概念どころか、Web上のCIという贅沢なサービスもありませんでし、GitHubもまだ存在してませんでした。

## 終わりに

当時自分が13\-14歳くらいのときに書いた、C言語のような粗悪なC\+\+コード、今見返すとひどいものです。[猫でもわかるWindowsプログラミング](http://www.kumei.ne.jp/c_lang/)のサンプルはどれもCだったので、その影響もあったのではと思います。
そのうちまた修正したいな。

