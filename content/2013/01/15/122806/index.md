---
title: メンバ変数ポインタの活用例
date: 2013-01-15T12:28:06+09:00
tags: [C/C++]
---

C言語には変数ポインタがあり，関数ポインタがあります．C\+\+ではメンバ関数ポインタがあり，メンバ変数ポインタもあります．  
メンバ変数ポインタは，インスタンスを指すポインタではなく，クラスのどこに変数があるかを指します．  
関数ポインタが理解出来ればメンバ関数ポインタが理解できるでしょうし，メンバ関数ポインタが理解出来ればメンバ変数ポインタが理解できると思います．

メンバ変数を使った例を示したいと思います．  
まず次のような関数を定義します．

```cpp
template <typename Object, typename Property>
Property get_value(const Object &obj, Property Object::*p) {
  return obj.*p;
}

template <typename Object, typename Property>
void set_value(Object *obj, Property Object::*p, const Property &v) {
  *obj.*p = v;
}
```

<span style="font-family:monospace">get_value()</span>関数はオブジェクトの参照とメンバ変数ポインタを受け取り，メンバ変数の値を返します．  
<span style="font-family:monospace">set_value()</span>関数はオブジェクトのポインタと変数ポインタ，新しい値を受け取り，メンバ変数に新しい値を代入します．

これらの関数を次のように使用します．

```cpp
struct Point {
  int x, y;
};

int main() {
  Point pt;

  set_value(&pt, &Point::x, 10);
  set_value(&pt, &Point::y, 20);

  std::cout << "x = " << get_value(pt, &Point::x) << std::endl;
  std::cout << "y = " << get_value(pt, &Point::y) << std::endl;
}
```

位置を格納する<span style="font-family:monospace">Point</span>構造体を宣言し，メンバ変数への参照・代入を外部から行なっています．

今回は簡単な例でしたが，例えば構造体のリストに対してメンバ変数に一斉に代入するときなどには便利かもしれません．

