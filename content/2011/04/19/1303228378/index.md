---
title: C言語で(無理やり)private
date: 2011-04-19T00:52:58+09:00
tags: [GomiScript, C/C++]
---

こんにちは  
C\+\+でのprivateをCで実装できないかなと作ってみた\.  
構造体と同じサイズの構造体をもうひとつ用意する\.  
ユーザはHoge構造体を使い, 構造体の設計者はデータを\(HogePrivate\*\)に変換してアクセスする\.  
実用性はさておきC言語でのお遊戯でした

```c
#include <stdio.h>

typedef struct __tagHogePrivate {
	int a;
	double b;
} HogePrivate;

typedef struct __tagHoge {
	char data[sizeof(HogePrivate)];
} Hoge;

void setInt(Hoge *hoge, int num) {
	((HogePrivate*)hoge)->a = num;
}
void setDouble(Hoge *hoge, double num) {
	((HogePrivate*)hoge)->b = num;
}
int getInt(const Hoge *hoge) {
	return ((HogePrivate*)hoge)->a;
}
double getDouble(const Hoge *hoge) {
	return ((HogePrivate*)hoge)->b;
}
int main() {
	Hoge hoge;

	setInt(&hoge, 1);
	setDouble(&hoge, 2.0);
	printf("%d\n", getInt(&hoge));
	printf("%f\n", getDouble(&hoge));

	return 0;
}
```

実行結果

```
1
2.000000
```

