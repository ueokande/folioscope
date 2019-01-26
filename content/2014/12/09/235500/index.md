---
title: VAIO Care for Linux
date: 2014-12-09T23:55:00+09:00
tags: [Linux, sh]
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2014/12/09/235500/20141210000400.png" alt="f:id:ibenza:20141210000400p:plain" title="f:id:ibenza:20141210000400p:plain" class="hatena-fotolife" itemprop="image"></span>

VAIO Proが届いて3日、Linuxを入れて快適に作業できています。[ArchWiki](https://wiki.archlinux.org/index.php/Sony_Vaio_Pro_SVP-1x21)を見て知ったのですが、VAIO特有のいたわり充電などの機能ががLinuxでも使えるそうです。`/sys/`以下からアクセスできるあたり、ハードウェアかミドルウェアあたりで制御しているのでしょうか。どちらにせよWindows固有でのドライバではなさそうなので、Linuxからも制御できるみたいです。

ファイルを直接触ってもいいのですが、せっかくなのでリッチなdialogを区使った設定ツールを作りました。
英語がひ弱なので、ぷるりく大歓迎です。

![github][ueokande/VAIO-Care]

* * *

こういったメーカーやハードウェア固有の設定をひとつのスクリプトにまとめるプロジェクト、あるんですかねぇ。

