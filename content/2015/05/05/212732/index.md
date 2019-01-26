---
title: C++でRubyのdoブロックっぽいこと
date: 2015-05-05T21:27:32+09:00
tags: [C/C++]
---

多くのケースの場合、メソッドに渡すクロージャは一つなので、Rubyのdoブロックのようにクロージャを書くための文法があるのは理にかなっている。C\+\+でも同じことはできないかなーと思って、少し書いてみた。

C\+\+の文法自体を変えることはできないけど、目を細めて見たら"λ = "に見えなくもない`/=`演算子をオーバーロドして、std::function<T>をパスできるArrayクラスを作ってみました。

# 使い方

```cpp
Array<char> array {'a', 'b', 'c', 'd', 'e'};

array.each /= [](char x){ 
  std::cout << x << std::endl;
};  

array.keep_if /= [](char x){
  return x <= 'c';
};  

array.each /= [](char x, int i){ 
  std::cout << i << ":" << x << std::endl;
};
```

おしりの`;`はどうすることもできなかった。残念。

全体のソースコードはこちら

- [https://gist\.github\.com/ueokande/1d2d4e5ef733f78949e7](https://gist.github.com/ueokande/1d2d4e5ef733f78949e7)

# 実行結果

- [\[Wandbox\]三へ\( へ՞ਊ ՞\)へ ﾊｯﾊｯ](http://melpon.org/wandbox/permlink/So4UIjZFTgQ0Z19a)

