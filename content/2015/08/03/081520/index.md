---
title: タッチバッドのスクロール機能を残したままマウス移動を無効化
date: 2015-08-03T08:15:20+09:00
tags: [Linux]
---

[{{<img src="http://farm5.staticflickr.com/4034/4363850853_a3f044bab5.jpg" alt="">}}](http://www.flickr.com/photos/46200603@N06/4363850853)  
[photo by kBoey pictures](http://www.flickr.com/photos/46200603@N06/4363850853)

ThinkPadは、タッチパッドとポインティングスティック（赤乳首）の両方が搭載されてます。
同じ機能がある部品が2つあるのは冗長で、キー入力中の誤感知などの問題もありますが、
無効化するには75mmx35mmの物理領域を占めるのでもったいないです。
そこでタッチパッドをスクロール専用デバイスにします。

# 参考 

- [synaptics: Add TouchpadOff=3 to disable pointer motion only \- Patchwork](http://patchwork.freedesktop.org/patch/12962/)

# パッチを当てる

まずsynapticsにパッチを当てるためにソースコードを取ってきます。
ディストリが配布しているSRPMなどから取ってくるのがよいです。
そして次の箇所を修正します。

<script src="https://gist.github.com/ueokande/bf4d522ff5c6d7137fd5.js"> </script><cite>[gist\.github\.com](https://gist.github.com/ueokande/bf4d522ff5c6d7137fd5)</cite>

あとはビルドしてインストールするだけ。`man synaptics`して、`Option "TouchpadOff" "integer"`の項に`3    Only pointer motion is switched off`が追加されていたらOKです。

# 設定する

`/etc/X11/xorg.conf.d/**-synaptics.conf` 辺りにあるsynapticsの設定で次を追加。

```
Option "TouchpadOff"  "3"
```

そして好きなスクロールを設定。

```conf
# エッジスクロール
Option "VertEdgeScroll" "on"
# 二本指スクロール
Option "VertTwoFingerScroll" "on"
# くるくるスクロール
Option "CircularScrolling" "off"
```

Xを再起動して、設定が反映されていることを確認すれば完了です。

