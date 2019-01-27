---
title: カウンタも剰余演算もないSleep FizzBuzz作ってみた
date: 2012-05-10T23:19:55+09:00
tags: [sh, GomiScript]
---

かなり前にsleepによってソートするSleep Sortが話題を呼びました  
[Genius sorting algorithm: Sleep sort](http://dis.4chan.org/read/prog/1295544154)  
比較演算がないユニークなソートです

今回はこれに影響されてSleep FizzBuzzを作ってみました  
sleepを使用するので剰余演算が必要ありません\.  
そしてカウンタは一秒ごとにタイマを進め, 初期時間との差分によって求めますので, 実質カウンタの実装はありません\.

