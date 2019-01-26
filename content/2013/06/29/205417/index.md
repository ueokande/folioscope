---
title: VAIO ProへのLinuxインストール
date: 2013-06-29T20:54:17+09:00
tags: [Linux]
---

Vaio Pro 11にLinuxのインストールおよびレポートがされています．

- [Sony Vaio Pro 11 with Ubuntu](https://spicious.com/sony-vaio-pro-11-with-ubuntu.html)

結果としては，鬼門といわれている無線LANや電源周りも問題なく動くそうです



* * *

このページ曰く，UbuntuをインストールするためにUEFIをBIOSに切り替え，GPTをMBRにフォーマットすることで起動したそうです．  
また無線LANドライバと，CPUの周波数・電圧をコントロールするP\-Stateを有効にするために，カーネルの書き換えとリビルドを行なっています．

導入まではやや手間がかかっていますが，動作には問題が無いとのこと．  
パフォーマンスの面は，Steamのほとんどのゲームにおいて，低か中程度の設定で1920x1080が十分に動作したそうです．

