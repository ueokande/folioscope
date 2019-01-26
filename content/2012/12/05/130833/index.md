---
title: constなメンバ関数の関数ポインタ
date: 2012-12-05T13:08:33+09:00
tags: [C/C++]
---

次のようなクラスの宣言があります．

```cpp
class MyClass {
public:
  void nonconstFunc() {}; 
  void constFunc() const {}; 
};
```

<span style="font-family:monospace">const</span>修飾子がついていないメンバ関数<span style="font-family:monospace">nonconstFunc()</span>と，<span style="font-family:monospace">const</span>修飾子がついている<span style="font-family:monospace">constFunc()</span>が宣言されています．

<span style="font-family:monospace">const</span>修飾子がついていないメンバ関数の関数ポインタは，調べればよく出てきます．

```cpp
void (MyClass::*func1)() = &MyClass::nonconstFunc;
```

<span style="font-family:monospace">const</span>修飾子がついているメンバ関数の関数ポインタは，調べれば出てこなかったのでメモ．

```cpp
void (MyClass::*func2)() const = &MyClass::constFunc;
```

