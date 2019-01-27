---
title: マルチ端末で作業場所と出力先を分ける
date: 2013-04-30T00:01:38+09:00
tags: [Linux]
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/04/30/000138/20130429171312.png" alt="f:id:ibenza:20130429171312p:plain" title="f:id:ibenza:20130429171312p:plain" class="hatena-fotolife" itemprop="image"></span>  
ナウい開発環境だと，コンパイル時のエーラが別ウィンドウで表示される．  
Vimでもできそうではあるが，Vimはあくまでも開発環境．  
シェルの出力結果を別端末に表示したい．

tmuxで作られた端末に対しても，ttyが割り当てられる．  
現在の端末は<span style="font-family:monospace">tty</span>コマンドで取得できる．

```
$ tty
/dev/ttys001
```

そしてもちろん，端末に対して文字を流しこむこともできる．

```
$ echo "Hello World" >/dev/ttys001
```

そこでコマンドの出力を別端末に流しこむことを，自分はよくする．

```
$ unzip hoge.zip >/dev/ttys001 2>&1
$ gcc foo.c >/dev/ttys001 2>&1
$ gcc bar.c >/dev/ttys001 2>&1
```

この例だと，現在の端末は<span style="font-family:monospace">unzip</span>や現在の端末は<span style="font-family:monospace">gcc</span>の出力を，<span style="font-family:monospace">ttys001</span>に流し込んでいる．  
作業場所と出力を切り替えることで，画面の小さい端末でも出力と作業場所を分けることで，効率的に作業ができるはずだ．



* * *

  
[execコマンドで出力先を切り替える](http://linux.just4fun.biz/逆引きシェルスクリプト/設定でstdout,stderrの出力先をファイルにする.html)こともできるけど，これだとプロンプトまで向こうの端末に飛ばされてしまう．  
もっと効果的な何かを模索中である．
