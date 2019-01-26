---
title: 悪質なプリプロセッサ
date: 2011-05-04T00:16:38+09:00
tags: [GomiScript, C/C++]
---

C/C\+\+では, コードのコンパイル前に, プリプロセッサという処理をします  
\#defineとか\#includeとかです  
このプリプロセッサの特徴をいかしたソースコードをご覧ください

  
C/C\+\+の予約語などの字句解析を行う以前に, プリプロセッサの処理が行われるので,  
doubleやcharといった予約語もお構いなしに, charにで置換されてしまいます

```cpp
#include <stdio.h>
#define double char
#define int char
int main()
{
    printf("%d %d\n", sizeof(int), sizeof(char));
}
```

実行結果

```
1 1
```

このプリプロセッサをヘッダファイルに埋め込んで上司に\#includeさせればGood\!\!  
\(一切の責任は負いかねます\)

