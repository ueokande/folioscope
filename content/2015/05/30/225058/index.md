---
title: LaTeXのビルドシステムとテンプレートプロジェクトを作りました
date: 2015-05-30T22:50:58+09:00
tags: 
---

TeX/LaTeXのややこしいビルド手順を、Makefileに起こして公開していましたが、TeX/LaTeXプロジェクトのテンプレートにPOWER UPしました。

{{<github src="ueokande/tex-makefile">}}

ディレクトリ構造は、Middleman風に、ソースコードをsourceディレクトリに配置します。またローカルなtexmfにも対応しており、このプロジェクトでしか使わないような\.clsファイルや\.styファイルを、プロジェクトのディレクトリに内に配置することもできます。

また次のサイトは、複雑なTeX/LaTeXのビルドの手順をわかりやすいアクティビティ図で説明しています。<iframe src="http://folioscope.hatenablog.jp/embed/2014/03/09/220819" title="Make-ing LaTeX - Folioscope" class="embed-card embed-blogcard" scrolling="no" frameborder="0" style="display: block; width: 100%; height: 190px; max-width: 500px; margin: 10px 0px;"></iframe>

<cite>[folioscope\.hatenablog\.jp](http://folioscope.hatenablog.jp/entry/2014/03/09/220819)</cite>

