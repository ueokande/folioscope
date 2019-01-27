---
title: ポインタ変数に付加機能をつける
date: 2012-04-08T11:36:47+09:00
tags: [C/C++, GomiScript]
---

変数は<span class="deco" style="font-weight:bold;">アライメント</span>といって, ある一定の倍数のアドレスに変数領域が確保されます\.  
アライメントは変数のサイズと同じことが多いですが, そう定義されているわけでもなく, 例外もあります\.  
アライメントについては次のサイトが詳しいです\.  
[http://www5d\.biglobe\.ne\.jp/~noocyte/Programming/Alignment\.html](http://www5d.biglobe.ne.jp/~noocyte/Programming/Alignment.html)

  
例えばアライメントが4の場合, 変数のアドレスは4の倍数となります\.  
そのため変数のアドレスは下位2ビットが常に0となります\.  
そこでこの下位2ビットに自由な情報を付加してみます\.

