---
title: TeX文章をmakeで管理
date: 2013-07-29T00:00:09+09:00
tags: [TeX/LaTeX]
---

<span style="color: #cc0000">更新しました</span>  
[http://folioscope\.hatenablog\.jp/entry/2014/03/09/220819](http://folioscope.hatenablog.jp/entry/2014/03/09/220819)



* * *

Makefileをかけると作業が数倍に跳ね上がります．Makefilleの書き方を公開している東大のエライ先生の言葉が身にしみます，

> コンピュータサイエンティストは非効率を嫌わなければなりません．
> 
> <cite>[トリビアなmakefile入門](http://www.jsk.t.u-tokyo.ac.jp/~k-okada/makefile/)</cite>

TeXの場合も，コンパイルが複雑なのでMakefileを書く価値は十分あります．TeX用に作ったMakefileのテンプレートを置いておきます．  

{{<github src="ueokande/tex-makefile">}}

以下，使い方です．

* * *

#### 簡単な使い方

まず<span style="font-family:monospace">Makefile.template</span>を編集し，<span style="font-family:monospace">Makefile</span>に保存します．<span style="font-family:monospace">Makefile</span>に書くオプションは，下のオプションの章を見てください．

PDFを生成するには，<span style="font-family:monospace">pdf</span>ターゲットで<span style="font-family:monospace">make</span>します．

```
make pdf
```

生成されたファイルを削除するには<span style="font-family:monospace">clean</span>ターゲットで<span style="font-family:monospace">make</span>します．

```
make clean
```

さらなるターゲットは<span style="font-family:monospace">help</span>ターゲットで知ることができます．

```
make help
```

#### オプション

### TARGET

コンパイルするルートのファイル名および，出力されるファイル名です．

### CLASS\_FILE

使用するクラスファイル名です．独自のクラスファイルを使用しない場合は空にします．

### TEX\_FILES

ドキュメント中に，<span style="font-family:monospace">\include</span>や<span style="font-family:monospace">\input</span>で使用しているTeXファイルを指定します．

### SVG\_FILES

挿入するSVGファイル名です．指定しておくとinkscapeでEPSに変換します．

### BIBTEX\_ENABLED

bibtexを使用するかどうかのオプションです．使用する場合は<span style="font-family:monospace">yes</span>を，使用しない場合はそれ以外の値か，空を指定します．これを指定しないと，コンパイルに失敗します．

### コンパイルコマンド

コンパイルに使用するコマンドで，以下のものを使用します．

```make
LATEX = latex
BIBTEX = bibtex
DVIPDF = dvipdfm
DVIPS = dvips
```

日本語を使用する場合は次のようにしてください．

```make
LATEX = platex
BIBTEX = pbibtex
DVIPDF = dvipdfmx
DVIPS = dvips
```

