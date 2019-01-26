---
title: 主婦でも出来る!? 算術演算子を使わない算術演算
date: 2011-07-18T21:42:42+09:00
tags: [GomiScript, C/C++]
---

算術演算子を使わない加算, 減算, そして乗算をご紹介いたします  
まず初めに, ポインタの演算について説明すると  
通常の算術演算の場合,

```
c = a + b
```

とすると, cには, aとbが加算された結果が代入されます\.  
さて, これがポインタのアドレス値になると少し違ってきます  
pが何かの型のポインタとしたとき, 

```
r = p + q
```

の場合, 加算されるのではなく, pからqだけポインタが進められます\.  
これはどういう事かというと, 例えばpがint型のポインタとしたとき, rにはint型の大きさとqが掛け合わされた数がpに加算された数が代入されます\.  
これを, 算術的に表すと, 次のとおりになります\.

```
c = a + b * t    (tはaの型の大きさ)
```

それでは実際にこれを使用して, 算術演算の実装を見ていきましょう\.
