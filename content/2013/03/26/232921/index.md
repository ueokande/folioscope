---
title: Linuxでwlanを使えるように頑張ってみた
date: 2013-03-26T23:29:21+09:00
tags: [Linux]
---

自分はLenovoのラップトップにLinuxを入れているが，Linux\-er泣かせの無線LANドライバに，自分も泣かされていた．おかげでしばらく，Wireful LAN状態で使用していた．

良心的なBroadcomはLinux用のドライバを公開していたので自分も入れてみたが，無線LANインタフェイス認識するものの全く使えない．しばらく調べていると，無線デバイスのオン・オフを切り替える<span style="font-family:monospace">rfkill</span>コマンドがあるらしいので，自分も使ってみた．すると次のような結果が表示された．

```
# rfkill list wifi
0: ideapad_wlan: Wireless LAN
	Soft blocked: no
	Hard blocked: no
3: phy1: Wireless LAN
	Soft blocked: no
	Hard blocked: yes
```

あきらかに何かがおかしい．wlanデバイスが2つも見える．<span style="font-family:monospace">Hard blocked</span>はソフトウェア的にインタフェイスを有効・無効化する．試しにマシン本体の無線デバイス切り替えスイッチをトグルしてみると<span style="font-family:monospace">ideapad_wlan: Wireless LAN</span>の<span style="font-family:monospace">Hard blocked</span>が切り替わった．

しかし気になる<span style="font-family:monospace">phy1: Wireless LAN</span>の物理スイッチであるが，本体のどこにもない．そこでキーボードを探してみると，Fn\+F5にマシンが電波を発しているボタンを発見した．試しに押してみると，<span style="font-family:monospace">phy1: Wireless LAN</span>が見事に有効となった．

不思議実装をするラップトップにLinuxを入れるには，トラブルを対処する覚悟が必要である．だが今回のような実装は予期していなかった．誰もが不幸せになる実装をするベンダーには，反省してほしいものだ．

