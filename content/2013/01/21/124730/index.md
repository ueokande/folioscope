---
title: 文字が化けたファイルを参照する．
date: 2013-01-21T12:47:30+09:00
tags: [Linux]
---

ファイル名が文字化けしていたり，他の言語で入力されていたりすると，コンソールからアクセスするときにファイル名が指定できなくて困る．  
不便だからとファイル名を変更しようにも，元ファイル名にアクセス出来ない．  
こうなると手も足も出ない．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/01/21/124730/20130119005648.png" alt="f:id:ibenza:20130119005648p:plain" title="f:id:ibenza:20130119005648p:plain" class="hatena-fotolife" itemprop="image"></span>

これを解決する方法はいくつかある．

#### ワイルドカードを使う

まずひとつはワイルドカードを使う方法だ．  
例えば

```sh
rm -rf -- *
```

とすれば，文字化けしているファイルを含む，すべてのファイルを消すことができる．  
しかしこの方法だと，特定のファイルへとピンポイントにアクセスするのが難しい．

#### ls/head/tailを使う．

もう一つの方法が，ls/head/tailを使用する方法だ．  
例えば<span style="font-family:monospace;">ls</span>したとき2番目に目的のファイルがあれば，次のようなコマンドでファイル名を表示できる．

```sh
ls | head -n2 | tail -n1
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/01/21/124730/20130119005652.png" alt="f:id:ibenza:20130119005652p:plain" title="f:id:ibenza:20130119005652p:plain" class="hatena-fotolife" itemprop="image"></span>  
<span style="font-family:monospace;">ls</span>の結果の上から2行を抜き出し，さらに下から1行を抜き出す．  
こうすることで<span style="font-family:monospace;">ls</span>の結果の2行目をピンポイントで抜き出せる．  
<span style="font-family:monospace;">head</span>や<span style="font-family:monospace;">tail</span>は行単位で処理するのに，グリッドで表示される<span style="font-family:monospace;">ls</span>を処理できるの？と思うかもしれないが，意外と相性がいい．  
試しに3番目のファイルを指定すると，<span style="font-family:monospace;">main.cpp</span>が帰ってくる．

ファイル名が返ってこればこっちのものなので，アクセスできる適当なファイルに変えてしまおう．

```sh
mv "`ls | head -n2 | tail -n1`" mojibake.png
```

