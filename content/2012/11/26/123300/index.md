---
title: gist-itの紹介
date: 2012-11-26T12:33:00+09:00
tags: [コラム・雑談]
---

github:gistというのがある．  
[Gist \- GitHub](https://gist.github.com/)  
これは断片的なコードをブログなどに公開するのに使われる．

github:gistの特徴として

- コードをembedでWebページに貼り付けられる
- バーション管理（差分管理・フォークなど）ができる
- URLを知らない人は見ることはできない

などがある．

断片的コード以上の書き捨てプログラムは，githubにpushして公開したい．  
そしてembedにしてブログにも貼り付けたい，という時にgist\-itというのが便利である．  
[gist\-it\.appspot\.com \- Embed files from a github repository like a gist](http://gist-it.appspot.com/)

使い方は簡単，次のフォーマットをブログ中に貼り付けるだけだ．

```html
<script src="http://gist-it.appspot.com/github/$user/$repository/raw/$branch/$path"></script>
```

  
例えば，

```html
<script src="http://gist-it.appspot.com/github/robertkrimen/gist-it-example/raw/master/example.js"></script>
```

というコードを貼ると，  
<script src="http://gist-it.appspot.com/github/robertkrimen/gist-it-example/raw/master/example.js"></script>  
という風に表示される．

