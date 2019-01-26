---
title: ブラウザ上のSVGとCanvasで1pxの線がぼやける訳
date: 2014-09-03T21:11:37+09:00
tags: 
---

先日、[ブラウザ上のSVGとCanvasで1pxの線がぼやける](http://folioscope.hatenablog.jp/entry/2014/08/25/192823:title)という記事を書きましたが、
原因はブラウザの実装ではなく、仕様をよく読まなかった自分でした。
同様の現象がStack Overflowにも投稿されていました。

[google chrome \- SVG rectangle blurred in all browsers \- Stack Overflow](http://stackoverflow.com/questions/18019453/svg-rectangle-blurred-in-all-browsers)

どうすればいいかというと、線を引く時\(10,5, 10,5\) のように、0\.5pxずらして描画すればいいとのこと。
どうしてその必要があるのかという言うと、例えばSVGやCanvasで\(1,1\)の地点から幅1pxの線を引くと、0\.5から1\.5の間に1pxの線が引かれます。

[![http://i.stack.imgur.com/74fN7.png](http://i.stack.imgur.com/74fN7.png)](http://i.stack.imgur.com/74fN7.png)  
Stack Overflowから抜粋

したがって描画するためには2素子をグレーにする必要があり、これがぼやけて表示されているように見えるのです。
確かに数学的な座標系と、コンピュータ上の素子との間にギャップがあるのが分かります。
そのため0\.5pxずらすことで、1pxの線が画面上の1素子を使用するようになるのです。

![f:id:ibenza:20140903210841p:plain](/2014/09/03/20140903210841.png)

