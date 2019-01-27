---
title: Mac/Qtの装飾キー
date: 2013-02-23T00:03:03+09:00
tags: [Qt, Mac]
---

Mac/Qtでの装飾キーの識別について．  
CtrlキーとCommandキーの割り当てについて，ドキュメントでは次のように述べられている．

> <span style="font-weight:bold">Qt::Key_Control</span> | On Mac OS X, this corresponds to the Command keys\.  
> <span style="font-weight:bold">Qt::Key_Meta</span> | On Mac OS X, this corresponds to the Control keys\.  On Windows keyboards, this key is mapped to the Windows key\. 
> 
> <cite>[http://doc\.qt\.digia\.com/stable/qt\.html\#Key\-enum](http://doc.qt.digia.com/stable/qt.html#Key-enum)</cite>

つまりMacでControlキーを押すとLinuxとかでのMetaキーが，Macでcommandキーを押すとLinuxとかでのControlキーが押されたとこになる．  
本来キーコードでは入れ替わっていなかったはずだが，移植性を優先した結果だろうか．  
QActionのショートカットも同様に，Mac上でcommandキーに割り当てたものが，LinuxとかではControlキーに割り当てられる．  
お陰で<span style="font-family:monospace">#ifdef</span>を書く必要がないので楽だ．

