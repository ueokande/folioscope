---
title: Qtのアニメーションのフレームレート
date: 2013-01-30T23:52:42+09:00
tags: [Qt]
---

QtにはQVariantAnimationやQPropertyAnimationなどのアニメーションクラスがある．  
そしてこれらのクラスを使った[サンプル](http://qt-project.org/doc/qt-5.0/qtwidgets/animation-animatedtiles.html)も存在するが，フレームレートや画面更新の管理をする記述が一切ない．  
これらのクラスが継承している[QAbstractAnimation](http://doc-snapshot.qt-project.org/5.0/qtcore/qabstractanimation.html)クラスのドキュメントでは

> normally be 60 updates per second
> 

ということらしい．  
これらのクラスを使う場合，フレームレートを気にしない場合が多いので，ユーザからは見えなくするのがいいのだろう．

