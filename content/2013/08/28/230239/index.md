---
title: Goodbye Thunderbird
date: 2013-08-28T23:02:39+09:00
tags: [コラム・雑談]
---

残念ながら自分の中でThunderbirdは終わりを迎えた．  
そもそもThunderbirdを使い始めた時から，いらない機能が多かった．  
現在ではSNSやカレンダーを備え，メーラとしての本意を失っている．  
その姿はまるで，腹に大きなフォアグラを抱えるガチョウのようである．

[Awesome](http://folioscope.hatenablog.jp/entry/2013/06/10/224610)に乗り換えてから，よりターミナル中心で作業するようになった．  
そこでメーラもCLIに乗り換えようと，Muttを使い始めてみた．  
CLIとはいえサイドバーも表示でき，Thunderbirdからの移行もスムーズに行えた．  
もちろんIMAPのフォルダにも対応しており，Gmailの数あるメールボックスにもアクセスできる．

### 今後の課題

Muttには残念ながら，新着メールの通知機能がない．  
特に不便はしていないが，メールに迅速に反応できないのは不安である．  
<span style="font-family:monospace">send-notify</span>でユーザに通知を送ることができ，Awesomeにも通知の表示が実装されている．  
そこでメールボックスを監視して<span style="font-family:monospace">send-notify</span>で通知するスクリプトを創案中である．

