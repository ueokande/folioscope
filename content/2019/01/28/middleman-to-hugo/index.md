---
title: ブログエンジンをMiddlemanからHUGOに移行した
date: 2019-01-27T17:20:54+09:00
---

{{<img src="hugo-logo.png" alt="HUGOのロゴ">}}

このブログ、以前は[Middleman][]でビルドしてたんですが、この度[HUGO][]に移行しました。
結論から言えば、機能的にはほぼ同じで移行も簡単でした（すでにこのブログも移行済みです）。
いくつか工夫する部分があったのでそれを記事にまとめました。

テンプレートエンジンの移行
--------------------------

HUGOはテンプレートエンジンにGoの`html/template`を使ってます。
HUGOではMiddlemanと同様 `partial` を使ってHTMLを外部ファイルとして記述できるので、パーツの共通化ができます。
MiddlemanからHUGOへの移行も、.erbファイルをGoのテンプレートに変換するだけで移行できました。
HUGOではMiddlemanと同じよう、テンプレート内から現在の記事のタイトルや全ての記事を取得できます。

MiddlemanではRubyで書いたヘルパメソッドをテンプレート内から呼び出せます。
そのため任意のRubyのコードをテンプレート内から実行できます。
一方HUGOは任意のGoコードを実行する機能がなく、テンプレート内のDSLも制約が多いです。
しかしテンプレート内で複雑なロジックを書くのは設計が間違ってると割り切り、そういう場合はが別の方法でドメインを分けようという方針にしました（後述するGitHubのリンクがそれに当てはまります）。

画像タグとShortcode
-------------------

HUGOに移行するとき、Markdownの画像記法 `![...](...)` ではなく、HUGOのShortcodeという機能を使うことにしました。
Shortcodeは外部に定義したHTMLを埋め込む記法で、本質的にはpartialと同じです。

```text
{{</*my_shortcode attr1="value1" attr2="value2"*/>}}
```

Middlemanでは画像記法 `![...](...)` の画像のパスを、HTML変換時に相対パスから絶対パスに変換します。
しかしHUGOは画像パスの変換をしないみたいです。
記事のページとトップページではURLのパスが異なるので、`src`属性は絶対パスである必要があります。

そこでHUGo移行後はMarkdownの画像記法ではなく、HUGOのShortcodeを採用しました。
自分のブログでは次のような記法で画像を埋め込めます。

```text
{{</*img src="screenshot1.png" alt="Screen shot 1"*/>}}
```

このShortcodeの定義は以下のようになってます。
Shortcodeに渡した`src`属性が相対パスのとき、記事のパスを先頭につけます。

```go-html-template
<figure>
  <img 
    class="article-image"
    {{ $link := .Page.RelPermalink }}
    {{- with .Get "src" }} src="{{ if not (strings.HasPrefix . "/") }}{{ $link }}{{ end }}{{ . }}"{{ end -}}
    {{- with .Get "alt" }} alt="{{.}}"{{ end -}}
  />
</figure>
```

ピュアなMarkdownで記述できないのは悔しいですが、任意のHTMLコードを埋め込むことができるようになったのでついでに`<figure>`タグで囲いました。

GitHubのリンク
--------------

ブログ内でGitHubのレポジトリを貼る時、以下のようなリンクにしてます。

{{<github src="ueokande/i-beam.org">}}

リンク内の情報（ユーザーアイコンや詳細）はJavaScriptで取得してるのではなく、事前に取得してHTML生成時に埋め込んでます。
MiddlemanではRubyのMarkdownエンジンを拡張して、独自のGitHubリンク記法を使ってました。
GitHubリンク記法でHTMLを描画する直前にGitHubから情報を取得してました。
MiddlemanにせよHUGOにせよこの方法はメンテナンス性に欠けるので、これを機に書き直しました。

HUGOには静的ファイル（JSON、YAML、TOML）からデータをロードする機能があります。
HUGO移行後は、GitHubのリンクを独自のShortcode `{{github src="******"}}` で記述できるようにしました。
GitHubリンクの情報を埋めるフローは以下のようにしました。

1. HTMLのビルド前に、Markdownファイルをスキャンして`{{github src="******"}}`からGitHubへのリンクを取得。
2. 取得したリポジトリ名一覧からリポジトリの情報を取得してJSONに保存。
3. Shortcode `{{</* github src="******" */>}}` でJSONからアイコンや詳細を取得

JSONファイルの中身は以下のとおりです。
これを全ての記事からレポジトリをかき集めて必要な情報を取得します。

```json
{
  "ueokande/bashvm": {
    "avatar_url": "https://avatars1.githubusercontent.com/u/534166?v=4",
    "url": "https://github.com/ueokande/bashvm",
    "description": "Bash Version Manager"
  },
  "ueokande/etcd-passwd": {
    "avatar_url": "https://avatars1.githubusercontent.com/u/534166?v=4",
    "url": "https://github.com/ueokande/etcd-passwd",
    "description": "Linux user managerment on etcd"
  },
  ...
}
```

HUGOからは `$.Site.Data.***` という名前で参照できます。
Shortcodeの定義は以下のようになってます。

```go-html-template
{{ $name := .Get "src" }}
{{ with index $.Site.Data.github $name }}
  {{ $fullname := index . "full-name" }}
  {{ $avatar_url := index . "avatar_url" }}
  {{ $url := index . "url" }}
  {{ $description := index . "description" }}
  <a href="{{ $url }}" class="external-link-github">
    <img class="external-link-github-avatar" src="{{ $avatar_url }}" />
    <span class="external-link-github-title">{{ $name }}</span>
    <span class="external-link-github-description">{{ $description }}</span>
    <span class="external-link-github-service">github.com</span>
  </a>
{{ else }}
  {{ errorf "GitHub data does not exist: %s" $name }}
{{ end }}
```

MarkdownからJSONを出力する処理は、[別スクリプトとして分離](https://github.com/ueokande/i-beam.org/tree/master/tools/update-static-enbed)しました。
ビルド手順は増えますが、それぞれの責務を明確に分離できてメンテナンス性は上がったと思います。

TwitterカードやOpen Graphのメタタグ
-----------------------------------

TwitterカードやOpen GraphのメタタグをHTML内に埋め込むと、サービス側がリンク先のメタタグを読んでいい感じに埋め込みリンクを生成します。
これらのメタタグを生成する機能も、HUGOにデフォルトで備わっています。

```go-html-template
{{- template "_internal/twitter_cards.html" . -}}
{{- template "_internal/opengraph.html" . -}}
{{- template "_internal/google_news.html" . -}}
{{- template "_internal/schema.html" . -}}
```

ただしデフォルトのメタタグは明示的に記事のFrontmatterで画像を指定しないと、メタタグに画像が指定されません。
そのため以下のようなタグを書いて、記事内の画像リソースからメタタグを生成するようにしました。

```go-html-template
{{ with .Page.Resources.ByType "image" }}
  {{ with index . 0 }}
    <meta name="twitter:card" content="summary_large_image">
    <meta property="og:image" content="{{ .Permalink }}">
    <meta name="twitter:image" content="{{ .Permalink }}">
  {{ end }}
{{ end }}
```

その他便利機能
--------------

### 記事一覧とページネーション

HUGOではページ一覧を `.Pages` で取得できます。
以下のように書くと記事一覧を`<p>`タグで描画します。

```go-html-template
{{ range .Pages }}
  <p>{{ .Title }}</p>
{{ end }}
```

また以下のように記述すると、日付の降順で一覧表示できます。

```go-html-template
{{ range .Pages.ByDate.Reverse }}
  <p>{{ .Title }}</p>
{{ end }}
```

`.Pages`では全記事をアクセスできますが、ページネーションしたい場合は以下のように書きます。

```go-html-template
{{ range .Paginator.Pages.ByDate.Reverse }}
  <p>{{ .Title }}</p>
{{ end }}
```

次のページと前のページへのリンクは`.Paginator.Prev`/`.Paginator.Next`で取得できます。

```go-html-template
<span>{{ with .Paginator.Prev }}<a href="{{ .URL }}">&lt;</a>{{ end }}</span>
<span>Page {{ .Paginator.PageNumber }} of {{ .Paginator.TotalPages }}</span>
<span>{{ with .Paginator.Next }}<a href="{{ .URL }}">&gt;</a>{{ end }}</span>
```

### 「あわせて読む」タグ

関連記事もHUGOデフォルトで取得可能です。
以下のように書くと、関連する記事を取得できます。


```go-html-template
{{ with $.Site.RegularPages.Related . | first 5 }}
  <h3>あわせて読みたい</h3>
  <ul>
    {{ range . }}
      <li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>
    {{ end }}
  </ul>
{{ end }}
```

### RSSフィード

HUGOはRSSフィードは自動で生成され、以下の記法でHTMl内にリンクを貼れます。

```go-html-template
{{ with .OutputFormats.Get "rss" -}}
  <link rel="{{ .Rel }}" type="{{ .MediaType.Type }}" href="{{ .Permalink }}" title="$.Site.Title" />
{{ end -}}
```


### シンタックスハイライト

Markdownのコードブロックの記法をシンタックスハイライトする機能がデフォルトで組み込まれてます。
設定ファイルに以下の設定を追記します。

```toml
pygmentsCodeFences = true
```

まとめ
------

MiddlemanらHUGOの移行はは、機能的に問題なく移行できました。
またこれを機にビルドプロセスも見直すことができました。

ビルド時間も減りました。
ビルドにかかる時間がMiddlemanでは20秒ほどだったのが、HUGOだと**1秒未満**になりました。
ビルド時間が短くなると、記事執筆のプレビューが早くて便利です。
また`.ruby-version`や`bundle install`も無くなったので、新規構築時の手間も減りました。

HUGOのユーザになるからには、機会があればコントリビュートもしてみたいと思います！


[Middleman]: https://middlemanapp.com/
[HUGO]: https://gohugo.io/
[text/template]: https://golang.org/pkg/text/template/
