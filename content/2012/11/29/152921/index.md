---
title: Qt Creatorの不思議実装
date: 2012-11-29T15:29:21+09:00
tags: [Qt, C/C++]
---

MacOS版のQt Creatorはver\.2\.6からフルスクリーンに対応しています．しかしQtのライブラリにはMac OSのフルスクリーンのためのAPIが用意されておらず，Cocoaのライブラリを叩く必要があります．ではQt Creatorではどのような実装になっているのでしょうか．

Qt Creatorのソースの<span style="font-family:monospace">$QTCREATOR/src/plugins/coreplugin</span>にメインウィンドウを始めとするコアのプラグインが入っています．このディレクトリの<span style="font-family:monospace">mainwindow.cpp</span>というファイルに次のような記述があります．

```cpp
#if defined(Q_OS_MAC)
#include "macfullscreen.h"
#endif
```

これでMac OSでコンパイルする場合は，フルスクリーン用のヘッダを読みに行きます．

そして<span style="font-family:monospace">macfullscreen.h</span>の実装は<span style="font-family:monospace">macfullscreen.mm</span>にあり，この中でCocoaのライブラリを呼び出しています．そう，<span style="font-family:monospace">macfullscreen.mm</span>はObj\-Cで実装されているのです．  
記述されているのがC\+\+でもObj\-Cでもgccでコンパイルでき，それぞれの\.cpp/\.mmごとにバイナリが生成されます．そして最後にリンカがシームレスに処理してくれます．

