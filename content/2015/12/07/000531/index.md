---
title: Bashでstdout/stderr/exit codeをキャプチャ
date: 2015-12-07T00:05:31+09:00
tags: [sh]
---

[Shell Script Advent Calendar 2015](http://qiita.com/advent-calendar/2015/shell-script) 7日目の記事です。BashのちょっとしたTipsです。Bashに限らないかも知れませんが、検証環境がBashしかありませんでした。

## 問題

Bashで `$(command)` と書くと、`command`がサブシェルで実行され、
stdout（標準出力）を変数に格納することができます．

```sh
hoge_value=$(echo 'hoge')    # hoge_value => "hoge"
```

ただしstderr（標準エラー出力）はキャプチャできません。
いま、stdoutとstderrへ出力し、100を返す関数があるとします。

```sh
out_err_and_exit() {
  echo "This is stdout"
  echo "This \\is \"tricky 'stdout"
  echo "This is stderr" >&2
  echo "This \\is \"tricky 'stderr" >&2
  return 100
}
```

この関数を愚直に `$(...)` で出力を受け取ろうとしても、取りこぼしたstderrが無残にもターミナルに表示されます。

```sh
stdout=$(out_err_and_exit)
```

それではstdout/stderr/exit code をそれぞれ `$stdout`, `$stderr`, `$status` に格納するにはどうすればよいのでしょうか？

## 解答

```sh
. <(
  out_err_and_exit \
    2> >(stderr=$(</dev/stdin); declare -p stderr) \
    1> >(stdout=$(</dev/stdin); declare -p stdout)
  declare -i status=$?
  declare -p status
)
```

以下のコードで、特殊文字も難なく表示できるのが確認できます

```sh
echo "stdout => $stdout"
echo "stderr => $stderr"
echo "status => $status"
```

## 解説

`out_err_and_exit` のコマンドの実行結果を、`>(...)` を使ってそれぞれサブシェルに投げています。
サブシェル内では受け取った出力が `/dev/stdin` 経由で参照できます。
なので `/dev/stdin` を `$(...)` で取得して、それを `$stdout`, `$stderr` 変数に格納します。
しかしサブシェル内のコードはサブシェル外に副作用が無いので、サブシェル外からは `$stdout`, `$stderr` にアクセスできません。
そこで `declare -p` の登場です。

組込みコマンド `declare` に `-p` オプションをつけると、evalできるフォーマットで変数の名前と値が表示されます。

```sh
declare -p SHELL    # => declare -x SHELL="/bin/bash"
```

`$stdout`, `$stderr` を `declare -p` して定義を出力し、
外側のシェルでその出力を評価すると、外部でも `$stdout`, `$stderr` が定義されます。
トップレベルのシェルでは、`.` コマンド \(= `source` コマンド\) に `. <(...)` して出力を評価させます。
問題ではexit codeも`$status`に格納するので、`. <(...)` 内で `$?` を `$status` に格納して、同様に `declare -p` してます。

## Bash 4\.0未満の場合（追記）

[@akinomyoga](http://qiita.com/akinomyoga)さんからコメントがありました。
Bash4\.0ではパイプから`source`できないバグがあるそうです。
代わりに`eval`を使って式を評価します。

```sh
eval -- "$(
  out_err_and_exit \
    2> >(stderr=$(</dev/stdin); declare -p stderr) \
    1> >(stdout=$(</dev/stdin); declare -p stdout)
  declare -i status=$?
  declare -p status
)"
```

* * *

この記事は [Shell Script Advent Calendar 2015](http://qiita.com/advent-calendar/2015/shell-script) 7日目の記事です。
明日は [@yudsuzuk](http://qiita.com/yudsuzuk) さんです。

- 6日目 [Bash で \(fish みたいな\) カラフルなコマンドライン \(ble\.sh\)](http://qiita.com/akinomyoga/items/22bbf8029e6459ed57ba)
- 8日目 [iPhone7等の新製品を誰よりも早く予約する為に、予約サイトがオープンしたらSlackに通知する方法](http://yuzurus.hatenablog.jp/entry/shell-slack)

