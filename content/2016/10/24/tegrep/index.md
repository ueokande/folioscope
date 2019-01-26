---
title: 温かみある、手grep作った
date: 2016-10-24T09:00:00+09:00
tags: [sh]
---

シェル芸人初心者や、grepコマンド使うより手動で選んだほうがいいという状況のために、手grepツール `tegrep` を作りました。

{{<img src="/2016/10/24/tegrep/tegrep/screenshot.gif" alt="Screenshot of tegrep">}}

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

