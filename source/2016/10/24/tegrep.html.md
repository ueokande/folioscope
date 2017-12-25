---
title: 温かみある、手grep作った
date: 2016-10-24 09:00 JST
tags: sh
---

シェル芸人初心者や、grepコマンド使うより手動で選んだほうがいいという状況のために、手grepツール `tegrep` を作りました。

![Screenshot of tegrep](/2016/10/24/tegrep/screenshot.gif)

![github][ueokande/tegrep]

使い方
------

通常のgrepのようにパイプでつなげるだけです。

```sh
command1 | tegrep | command2
```

あるいはファイルから読み出すこともできます。

```sh
tegrep file
```

`tegrep` は `$EDITOR` 環境変数を見ます。また `$EDITOR` がセットしていないときは `edit` コマンドが発動します。

