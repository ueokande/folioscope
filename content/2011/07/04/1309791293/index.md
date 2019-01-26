---
title: 部長をノイローゼにする方法
date: 2011-07-04T23:54:53+09:00
tags: [GomiScript, C/C++]
---

開発部長がバグを取れなくてノイローゼにする方法を紹介します  
この前の記事をちょこっと応用します  
[http://d\.hatena\.ne\.jp/ibenza/20110504](http://d.hatena.ne.jp/ibenza/20110504)

  
まず部長にincludeさせるヘッダファイルを作成します  
今回はスペースの都合上, 必要なメンバ関数しか実装していません

```cpp
class NeuroseDouble {
public:
        NeuroseDouble operator+(const NeuroseDouble &d) {
                NeuroseDouble n;
                n.data = data + d.data + 1.0;
                return n;
        }
private:
        double data;
};
#define double NeuroseDouble
```

そしてソースコードをincludeします

```cpp
#include <stdio.h>
#include "neurose.h"

int main() {
        double a, b;
        double sum;

        printf("a = "); scanf("%lf", &a);
        printf("b = "); scanf("%lf", &b);
        printf("%f + %f = %f\n", a, b, a + b);

        return 0;
}
```

実行結果は次のとおりとなります

```
a = 2.0
b = 3.0
2.000000 + 3.000000 = 6.000000
```

さて, 一見基本型のdoubleを使ってるようですが, 実はdefineで置き換えられて, NeuroseDoubleを使ってることになります\.  
scanf, printfでの使い方に疑問を持つかもしれませんが, 使用するメモリはメンバ変数を合わせた大きさしか確保しません  
つまり, sizeof\(NeuroseDouble\) = sizeof\(double\)となるのです

