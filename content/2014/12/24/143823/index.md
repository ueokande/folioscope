---
title: JBL PebblesをLinuxで
date: 2014-12-24T14:38:23+09:00
tags: 
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2014/12/24/143823/20141224143747.jpg" alt="f:id:ibenza:20141224143747j:plain" title="f:id:ibenza:20141224143747j:plain" class="hatena-fotolife" itemprop="image"></span>

> USBを伝わってデジタル信号でスピーカーに伝搬するので、音にメリハリが出ました。しかしボリュームコントロールがLinuxで動作しなかったので、星4つです<span style="color: #f9ce1d">★★★★☆</span>
> 

<span style="color: #ff0000">2015-01-11 追記 : Linuxでもフツーに動きました。</span>

結果からいうと、USBでもスピーカーが普通に使えましたが、音量調節機能が使えませんでした。

# ALSAの設定

特に特殊なことをせずに、USBにブスリとするだけで認識した。ALSAの設定で、デフォルトのカードを指定する。
番号で指定しても、再起動ごとに番号が変わるので、デバイス名で指定。

```conf
# /usr/share/alsa/alsa.conf

defaults.ctl.card Pebbles
defaults.pcm.card Pebbles
```

デバイス名で指定している例が無かったので、正しいのかわからないけど、とりあえず音出てるので大丈夫っぽい。

# 音量調整

本体のボリュームコントロールをくるくる回すと、WindowsやOS Xのの音量を調節できるらしい。  
ただしLinuxでは、どう頑張っても使えなかった。
ラップトップやキーボードからの音量調整は、キーコード `XF86Audio******` のKeyPressが送られる仕組みだが、
この製品に限っては異なるようだ。`xev`でキャプチャしてもそれっぽい信号が来ない。
ただしFocusOutやFocusInやKeymapNotifyなどのイベントが発生しているようなので現在調査中。

どうやってWindowsやOS Xで音量調節しているかは謎。

# 2015\-01\-11 追記

Linuxでもフツーに動きました。ボリュームコントロールすると、XF86AudioRaiseVolumeとXF86AudioLowerVolumeキーのイベントが飛んでくるので、それに音量調整のコマンドを指定すればOKです。

