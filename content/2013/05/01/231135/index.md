---
title: My Xmodmap
date: 2013-05-01T23:11:35+09:00
tags: [Linux]
---

[コンソールでのキーマップをカスタマイズ](http://folioscope.hatenablog.jp/entry/2013/01/16/121959)の記事でCaps Lockにコントロールを割り当て，UnderscopeをMacっぽくカスタマイズした．  
X11の環境では，カスタマイズ方法が違う．  
X11では（正確にはXmodmapを使用する環境では），ホームにある\.Xmodmapを編集する．

### Caps Lockを左Controlに

```
remove Lock = Caps_Lock
keysym Caps_Lock = Control_L
add Control = Control_L
```

### underscoreをMacっぽく

```
keycode 97 = underscore underscore
```

ファイルの設定ができたら，次のコマンドで新しい設定をロードする．

```
xmodmap ~/.Xmodmap
```

うまく動けばOK

