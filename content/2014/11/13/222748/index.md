---
title: ターミナルでバッテリの状態を取得
date: 2014-11-13T22:27:48+09:00
tags: [Linux, sh]
---

ターミナルでバッテリー残量が表示できれば便利ですね。Linuxだと/sys/class/power\_supply/BAT\*にバッテリー情報があります。
デバイスをファイルとしてアクセスできるのは便利ですね。
それが黒い画面でも取得すれば便利という話。

<script src="https://gist.github.com/ueokande/69f1c5494d7fb3779fb7.js"> </script>

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2014/11/13/222748/20141113212842.png" alt="f:id:ibenza:20141113212842p:plain" title="f:id:ibenza:20141113212842p:plain" class="hatena-fotolife" itemprop="image"></span>

あとはプロンプトに表示するもよし、figletに投げるもよし。

