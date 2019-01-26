---
title: QMLでウィンドウっぽく
date: 2012-06-17T01:20:57+09:00
tags: [C/C++, Qt]
---

![f:id:ibenza:20120617010751p:plain,right](/2012/06/17/012057/20120617010751.png)  
QtQuickの開発が進んで, QMLも充実してきました\.  
[Introduction to Qt Quick | Documentation | Qt Developer Network](http://qt-project.org/doc/qt-4.8/qml-intro.html)  
Qtの方針も, \(簡単な\)UIはQMLで, 高度なロジックはC\+\+でするという方針なようです\.  
なにより綺麗なUIが容易に作成できるというのが大きな強みです\.

今回はQMLで書いたものをウィンドウっぽいものを作ります\.

READMORE
QMLの表示はQDeclarativeViewで行います\.  
普通にQDeclarativeViewでQMLファイルを表示するとこうなります\.  
![f:id:ibenza:20120617010805p:plain](/2012/06/17/012057/20120617010805.png)  
ここから背景を透過しフレームを消します\.

```cpp
QDeclarativeView view("main.qml");
viewer.setWindowFlags(Qt::FramelessWindowHint);
viewer.setAttribute(Qt::WA_TranslucentBackground);
viewer.viewport()->setAttribute(Qt::WA_TranslucentBackground);
```

QDeclarativeViewはQAbstractScrollAreaを継承しているので, 背景を透過するにはQAbstractScrollArea::viewport\(\)でスクロールエリアのQWidgetも透過する必要があります\.  
これによりQMLのみの表示を行うことができます\.  
![f:id:ibenza:20120617010815p:plain](/2012/06/17/012057/20120617010815.png)

