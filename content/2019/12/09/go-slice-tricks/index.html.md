---
title: 図解 Go Slice Tricks
date: 2019-12-09T09:00:00+09:00
tags: [Go]
cover: cover.png
---

この記事は[Go7 Advent Calendar 2019][go7-advent-calendar-2019]の記事です。

GoにはJavaやRubyなどのモダン言語のようなsliceを操作する関数は用意されていません。
Goではbuilt-in関数の`append()`や`copy()` とfor構文を組み合わせることで、他の言語にあるようなslice操作を実装できます。
この記事ではそれぞれのslice操作を図解で解説します。

元ネタはGo公式Wikiにある[Go SliceTricks - golang/go Wiki][go-slice-tricks]です。

## Sliceの連結

{{<img alt="sliceの連結" src="./AppendVector1.svg">}}
{{<img alt="sliceの連結" src="./AppendVector2.svg">}}

```go
a = append(a, b...)
```

コピー先 `a` にコピー元の `b` の全ての要素をコピーします。
連結後の長さが `cap(a)` を超える場合は、新たなsliceが作成されて `a`、`b`ともにコピーします。

以降は`append()`のコピー先には十分な`cap`があるという前提で進めます。

## 複製

{{<img alt="sliceのコピー" src="./Copy.svg">}}

slice `a` から新たなslice `b` を複製します。
以下のいずれかの方法で複製できます。

```go
b = make([]T, len(a))
copy(b, a)
```

```go
b = append([]T(nil), a...)
```

コピー元 `a` が空かnilかを区別する場合は、以下のように書きます。
`a` がnilの場合は`b`がnilになり、`a`が空の場合は`b`が空になります。

```go
b = append(a[:0:0], a...)
```

## 範囲の削除

{{<img alt="範囲の削除" src="./Cut.svg">}}

```go
a = append(a[:i], a[j:]...)
```

範囲を指定して削除します。
`a[:i]` までを切り出して、`a[j:]` の各要素を `a[i]` 以降にコピーします。

## 単一要素の削除

```go
a = append(a[:i], a[i+1:]...)
```
```go
a = a[:i+copy(a[i:], a[i+1:])]
```

{{<img alt="単一要素の削除" src="./Delete1.svg">}}

`a[:i]` を切り出して、`a[i+1:]` の各要素を `a[i]` 以降にコピーします。

## 順序保証しない単一要素の削除

{{<img alt="順序保証しない単一要素の削除" src="./DeleteWithoutPreservingOrder.svg">}}

```go
a[i] = a[len(a)-1]
a = a[:len(a)-1]
```

要素の順序が重要じゃない場合は、末尾の要素を削除対象の要素にコピーできます。
この方法は「単一要素の削除」と比較して、コピーが1回で済みます。

## 範囲の削除 (GC)

{{<img alt="範囲の削除 (GC)" src="./CutGC.svg" >}}

```go
copy(a[i:], a[j:])
for k, n := len(a)-j+i, len(a); k < n; k++ {
	a[k] = nil // or the zero value of T
}
a = a[:len(a)-j+i]
```

要素がポインタ、またはポインタを持つstructの場合、上記の「範囲の削除」でメモリリークが発生します。
なぜならコピー前に末尾にあった要素がポインタへの参照を持ち続け、garbage collection (GC) が働かないためです。
これを回避するために、要素のコピー後に使わなくなった要素にnilまたはゼロ値で参照を消します。

## 単一要素の削除 (GC)

{{<img alt="単一要素の削除 (GC)" src="./DeleteGC.svg" >}}

```go
if i < len(a)-1 {
	copy(a[i:], a[i+1:])
}
a[len(a)-1] = nil // or the zero value of T
a = a[:len(a)-1]
```

「単一要素の削除」も同様に、使わなくなった要素をnilまたはゼロ値で参照を消します。

## 順序保証しない単一要素の削除 (GC)

{{<img alt="順序保証しない単一要素の削除  (GC)" src="./DeleteWithoutPreservingOrderGC.svg" >}}

```go
a[i] = a[len(a)-1]
a[len(a)-1] = nil
a = a[:len(a)-1]
```

「順序保証しない単一要素の削除」も同様に、使わなくなった要素をnilまたはゼロ値で参照を消します。

## 途中に要素を追加

{{<img alt="途中に要素を追加" src="./Expand.svg" >}}

```go
a = append(a[:i], append(make([]T, j), a[i:]...)...)
```

途中に要素を追加して要素を拡張します。
新たに長さ `j` のsliceを作成し、その末尾に`a[i:]` を追加します。
その結果を `a[i]` 以降にコピーします。

## 末尾に要素を追加

{{<img alt="末尾に要素を追加" src="./Extend.svg" >}}

```go
a = append(a, make([]T, j)...)
```

末尾に要素を追加して要素を拡張します。
新たに長さ `j` のsliceを作成し `a` の末尾に追加します。

## フィルター(in place)

{{<img alt="フィルター(in place)" src="./Filter.svg" >}}

```go
n := 0
for _, x := range a {
 if keep(x) {
  a[n] = x
  n++
 }
}
a = a[:n]
```

条件のマッチする要素のみを残します。
新たなsliceを作るのではなく、マッチする要素をsliecの先頭から詰めて、最後に長さを切り詰めます。

## 要素の挿入

{{<img alt="挿入" src="./Insert.svg" >}}

```go
a = append(a[:i], append([]T{x}, a[i:]...)...)
```

途中に要素を挿入します。
要素`x`のみを含む長さ1のsliceの末尾に `a[i:]` を連結し、それを`a[i]`以降にコピーします。

## sliceの挿入

{{<img alt="sliceの挿入" src="./InsertVector.svg" >}}


```go
a = append(a[:i], append(b, a[i:]...)...)
```

途中にsliceを挿入します。
挿入するslice `b` の末尾に `a[i:]` を連結し、それを `a[i]` 以降にコピーします。

## Push

{{<img alt="Push" src="./Push.svg" >}}

```go
a = append(a, x)
```

末尾に要素 `x` を追加します。

## Pop

{{<img alt="Pop" src="./Pop.svg" >}}

```go
x, a = a[len(a)-1], a[:len(a)-1]
```

末尾の要素を取り出し、長さを1つ切り詰めます。

## Push Front/Unshift

{{<img alt="Unshift" src="./Unshift.svg" >}}

```go
a = append([]T{x}, a...)
```

追加する要素を持つ長さ1のsliceの末尾に `a` を連結したのを、新たな `a` とします。

## Pop Front/Shift

{{<img alt="Shift" src="./Shift.svg" >}}

```go
x, a = a[0], a[1:]
```

先頭の要素を取り出し、`a{1:]` を新たな `a` とします。

## おわりに

以上[Go SliceTricks - golang/go Wiki][go-slice-tricks]の図解による解説でした。
GoにはGCがあるとはいえ、Cと同じようにポインタを意識したほうが、よりよいGoのコードが記述できます。
そのとき、このslice操作はコピーが発生するのか否かを考えられると、ハイパフォーマンスなプログラムが作れます。
解説した操作と図は、以下のサイトにチートシートとしてまとめてあります。

- [Go Slice Tricks Cheat Sheet](https://ueokande.github.io/go-slice-tricks/)

[go7-advent-calendar-2019]: https://qiita.com/advent-calendar/2019/go7
[go-slice-tricks]: https://github.com/golang/go/wiki/SliceTricks
