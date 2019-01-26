---
title: operator!=のオーバーロードを省く
date: 2015-05-20T08:58:10+09:00
tags: [C/C++]
---

`operator==` がオーバーロードされていたら、 `operator!=` の値は自明なので、定義を省きたい。

```cpp
struct Num {
  Num(int x) : x(x) {}
  bool operator==(Num y) const { return x == y.x; }
  int x;
};
```

というクラスを定義したときに、Numクラスの比較結果は、

```cpp
Num(0) == Num(0); // 1
Num(0) == Num(1); // 0
Num(0) != Num(0); // コンパイルエラー
Num(0) != Num(1); // コンパイルエラー
```

これを回避するにはグローバルな場所に `T` に対する`operator!=` を定義する。

```cpp
template <typename T>
bool operator!=(const T &x, const T &y) { return !(x == y); }
```

ただしグローバルな場所を汚染するので、バッドノウハウ過ぎて実用性は不明。
なお `>``<=``>=` も、`operator<` と `operator==` より一意に決まる。

