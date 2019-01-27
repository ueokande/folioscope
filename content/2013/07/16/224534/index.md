---
title: xdg-suを設定
date: 2013-07-16T22:45:34+09:00
tags: [Linux]
---

<span style="font-family:monospace">xdg-su<span>は管理者権限が必要なコマンドを実行するための，suを呼び出すインターフェイスである．<br>
このコマンドは環境に合わせて，<span style="font-family:monospace">kdesu<span>, <span style="font-family:monospace">gnomesu<span>, <span style="font-family:monospace">xterm<span>を呼び出す．<br>
私は現在awesomeを使用しているが，タイル型WMで<span style="font-family:monospace">xterm<span>のダイアログが表示され続けることが目障りである．<br>
そのため<span style="font-family:monospace">xdg-su<span>から<span style="font-family:monospace">gnomesu<span>を呼び出すようにする．</span></span></span></span></span></span></span></span></span></span></span></span></span></span>

結論から述べると，<span style="font-family:monospace">xdg-su<span>には呼び出すコマンドの設定はない．<br>
どうやってコマンドを切り替えているかというと，環境変数から現在のデスクトップ環境を検出している．<br>
詳しい動作は<span style="font-family:monospace">xdg-su<span>の仕様書（ソースコード）をみてみると良い．</span></span></span></span>

```sh
$ vi `which xdg-su`
```

<span style="font-family:monospace">xdg-su<span>がGnomeと認識するために，環境変数を設定すれば良い．<br>
ここでは<span style="font-family:monospace">.xinitrc<span>に次のコードを追加する．</span></span></span></span>

```sh
# .xinitrc
if [ "$DESKTOP_SESSION" = "awesome" ]; then
  export XDG_CURRENT_DESKTOP="GNOME"
fi
```

設定が終わると，ログインしなおして，<span style="font-family:monospace">xdg-su<span>コマンドで確認をする．<br>
自分が環境変数を書き換えることに抵抗があるが，今のところ問題になっていないのでよしとする．</span></span>

