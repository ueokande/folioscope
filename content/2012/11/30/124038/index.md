---
title: ソースコードの総行数を取得する
date: 2012-11-30T12:40:38+09:00
tags: [sh]
---

C\+\+を例に，ソースツリーのルートディレクトリに移動して次のコマンドを実行するだけ

```sh
find -regex ".*\.h\|.*\.cpp" | xargs wc -l | tail -n 1
```

気持ちよく1行で書けると脳内物質が出ているのを感じとれる
