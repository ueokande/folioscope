---
title: Qt Creatorで名前空間内のクラスを生成する
date: 2012-12-10T12:45:54+09:00
tags: [C/C++]
---

Qt Creatorのクラスウィザードを使ってクラスを作る場合，名前空間に属するクラスもサクッと作ることができます．方法は簡単，クラスウィウィザードのクラス名に，スコープ解決演算子<span style="font-family:monospace">::</span>のように名前空間をクラス名の前につけて，<span style="font-family:monospace">&lt;namespace identifier&gt;::&lt;class identifier&gt;</span>のようにします．

例えば<span style="font-family:monospace">hoge::fuga::piyo</span>のようにすると，次のようなコードを生成します．

```cpp
#ifndef HOGE_FUGA_PIYO_H
#define HOGE_FUGA_PIYO_H

namespace hoge {
namespace fuga {

class piyo
{
public:
    piyo();
};

} // namespace fuga
} // namespace hoge

#endif // HOGE_FUGA_PIYO_H
```

