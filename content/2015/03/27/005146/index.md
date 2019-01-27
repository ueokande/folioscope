---
title: asset pipelineとうまく付き合う
date: 2015-03-27T00:51:46+09:00
tags: [Ruby]
---

Railsの、初心者をハマらせる目玉機能といえば、asset pipeline。
そしてそいつといつも仲がいい、turbolinks。
この一見悪そうだが、実はできる奴らとのつきあい方をご紹介。

# それぞれの機能の簡単な紹介

## asset pipeline

開発中にバラバラに書いていたJSやCSSをひとつにまとめます。CoffeeScriptやSassも予めコンパイルし、ページロード時には単一のJSやCSSを提供します。
しかし単一のファイルになるので、意図しないviewを汚染してしまう。
viewごとに分割したファイルをロードすることで問題は回避できますが、asset pipelineの旨味が半減なのでやらない。

## turbolinks

assets pipelineと相性が良いのが、turbolinks。
こいつはページの遷移をajaxで済ませ、遷移先のページで使ってるCSSやJSが同一なら、
そちらはロードしない。
ユーザにも優しくネットワークにも優しい。
つまりCSSやJSをひとつのファイルにまとめるasset pipelineとはとても相性が良い。
ただしturbolinksも、遷移先のページでJSのイベントが発生しないなどの問題が。

# asset pipelineを考えたCSS

他のviewを汚さないようにCSSを記述する方法といえば、
DOMとCSSを階層で分けること。
しかし深すぎる階層は目を殺します。
そこでbodyタグのclassに書いちゃいます。`application.html.erb`のbodyに対して

```eruby
<body class="<%= controller_name %> <%= action_name %>">
```

すると、BooksController\#indexでレンダリングされるHTMLは、

```html
<body class="books index">
```

となります。そして各コントローラのcss、例えばbooks\.css\.scssには、

```sass
// books.css.scss

.books {
  /* BookController共通のスタイル */
}
.books.index {
  /* BookController#indexのスタイル */  
}
.books.show {
  /* BookController#showのスタイル */  
}
.books.new {
  /* BookController#newのスタイル */  
}
.books.edit {
  /* BookController#newのスタイル */  
}
```

ほどよいインデント量で綺麗にスコープの分離ができました。

# turbolinksを考えたJS

jquery\.turbolinksという便利なjQueryプラグインを使うと、

{{<github src="kossnocorp/jquery.turbolinks">}}

ページの遷移時に`$(document).ready()`が発火します。
しかし何も考えずに`$(document).ready()`を配置すると、意図しないcontrollerやactionでも初期化処理が起こります。
そこで初期化処理を以下のように工夫。

```coffee
# books.js.coffee

onready = {}
onready['index'] = ->
  # BooksController#indexの初期化処理
onready['show'] = ->
  # BooksController#showの初期化処理
onready['new'] = ->
  # BooksController#newの初期化処理
onready['edit'] = ->
  # BooksController#editの初期化処理

$(document).ready ->
  return if controller_name != 'books'
  onready[action_name]() if onready[action_name] isnt undefined
```

# 最後に

asset pipelineやturbolinks周りの対応が面倒で、かつ周りのRails人に聞いても、答えがまちまち。
もしかしたら決定的な方法は特に無いのでは。
自分なりの書き方をまとめたのですが、もう少しかっちょいい書き方があったら教えてください。

