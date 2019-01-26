---
title: Tex Live 2013 が壊れている疑惑
date: 2013-12-09T19:47:54+09:00
tags: [openSUSE, TeX/LaTeX]
---

遅れながらも[<span style="color: #008800">openSUS 13.1</span>](http://software.opensuse.org/131/ja)をインストールしました。

<span style="font-size:200%">が、</span>

```sh
$ dvipdfmx index.dvi

** WARNING ** Could not open config file "dvipdfmx.cfg".

...
```

<span style="font-size:200%">WHAT!!!!!!!!???</span>

なんてこったい，`dvipdfmx.cfg`が見当たらぬと。
「どうせ`mktexlsr`していないんでしょう？」「どうせ`texmf`の設定がおかしいいんでしょう？」なんてお思いの方。
バッチリチェック済みでござる（たしかデフォルトでもコンパイルが通るように設定されていたはず）。

WARNINGだからってバカに出来ない。
埋め込んだ画像のコンパイルルールを読みに行かないから、画像が埋め込まれているドキュメントがコンパイルできない。
他にも`dvipdfmx`の設定が色々と読み込まれない。

確かな原因はわからぬが、openSUSE 12\.3のTex Liveは2012、openSUSE 13\.1のTex Liveは ver\.2013。
壊れているのは本流のTex LiveかopenSUSEのTex Liveか、よくわかりません。
一日かけてあれやこれやと突いてみたものの、結局原因はわからず。
なんとか回避法だけ見いだせました。

# 回避法

`dvipdfmx.cfg`を（あるいはシンボリックリンクを）コンパイルするドキュメントの作業ディレクトリに作るだけ。

```sh
$ ln -s /etc/texmf/dvipdfmx/dvipdfmx.cfg path_to_working_directory
```

