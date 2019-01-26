---
title: コンテナのコンテナのforeach
date: 2013-09-16T22:48:18+09:00
tags: [C/C++, boost]
---

Boostには`BOOST_FOREACH`マクロがあり，他の言語でのforeachが気軽に書ける．
しかし`std::list<std::pair<T1, T2> >`などの，コンテナのコンテナを扱うときには少し気を使う必要がある

```cpp
std::list<std::pair<int, float> > list_of_pair;
BOOST_FOREACH (const std::pair<int, float> &pair, list_of_pair) {
}
```

やりたいとこは伝わるが，コンパイルエラー．
コンマが2つあるので．マクロに3つの引数と解釈される．

### 部分点がもらえる正解

コンパイルは通り，希望通りの動作はするが，`pair`のコピーにムダなオーバーヘッドが発生する．
これではC\+\+の哲学に反する．

```cpp
std::pair<int, float> pair;
BOOST_FOREACH (pair, list_of_pair) {
}
```

### 合格点がもらえる正解

`typedef`を使って`Pair`を宣言する方法．
おそらくこれが正解．

```cpp
typedef std::pair<int, float> Pair;
BOOST_FOREACH (const Pair &pair, list_of_pair) {
}
```

### 新しいもの好きな人向け

C\+\+11からrange\-based forが使えるので，一番綺麗に書くことができる．C\+\+11ユーザは素直にこっちを書きましょう．

```cpp
for (const std::pair<int, float> &pair : list_of_pair) {
}
```

