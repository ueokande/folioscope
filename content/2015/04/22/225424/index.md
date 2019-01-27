---
title: std::tupleのhead/last/init/tail
date: 2015-04-22T22:54:24+09:00
tags: [C/C++]
---

今日は久しぶりにC\+\+っぽいコードを書いていた。僕の知識もC\+\+03止まりだったので、`std::tuple`を操作するメタメタしいプログラムを書いてみた。`std::get`にsize\_t\.\.\.を渡して展開するの面倒だなーと思ってたら、`std::index_sequence`という、便利なヘルパクラスもあることを学びました。autoやconstexprやその他いろいろ、便利な時代になりました。

<script src="https://gist.github.com/ueokande/e7c7cf45c26b1e79cf27.js"> </script><cite>[gist\.github\.com](https://gist.github.com/ueokande/e7c7cf45c26b1e79cf27)</cite>

- 実行結果  
[\[Wandbox\]三へ\( へ՞ਊ ՞\)へ ﾊｯﾊｯ](http://melpon.org/wandbox/permlink/DdPLDfl4WyujB8IX)

