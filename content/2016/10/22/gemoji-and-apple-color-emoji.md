---
title: GitHubとAppleのEmoji
date: 2016-10-22T09:02:00+09:00
tags: [コラム・雑談]
---

GitHubを始めとする様々なWebサービスでAppleColorEmojiをよく見ますが、ライセンスはどうなっているか調べてみました。

GitHub上のEmojiが変わった
-------------------------

GitHubのEmojiが変更されました。自分の環境ではAppleColorEmojiで表示されているのですがTwitter上で同じことを報告しているユーザがいたため、自分の思い違いではなかったようです。

> [@github](https://twitter.com/github) has changed the emojis on site once again. These ones are looking pretty ugly though. :( [#github](https://twitter.com/hashtag/github?src=hash) [#emoji](https://twitter.com/hashtag/emoji?src=hash)
>
> ![new-gemoji](/2016/10/22/gemoji-and-apple-color-emoji/CuJ4poxVYAQnoab.jpg)
>
> <cite>[@amit\_merchant](https://twitter.com/amit_merchant/status/784322193853259776)</cite>

GitHubのEmojiは以前からAppleColorEmojiが使用されていましたが、ライセンスについて前から気になってました。なのでこれを機会に少し調べてみました。

AppleColorEmojiとgemoji
-----------------------

GitHubのEmojiは[github/gemoji](https://github.com/github/gemoji)というリポジトリで管理されています。
このリポジトリで以下のような議論がされていました。

> the images from AppleColorEmoji are :copyright: by Apple, and as such, their
> distribution is a violation of copyright law.
>
> <cite>[Replace emoji with opensource versions by paradox460 · Pull Request #64 · github/gemoji](https://github.com/github/gemoji/pull/64)</cite>

どうやらAppleColorEmojiを二次配布するのはライセンス違反だそうです。GitHubがAppleと提携していなかったことに驚きですが、ライセンス違反のままずっと配布されていたのも驚きです。この議論が始まったのがおよそ2年前ですが、本格的に削除が決定したのはここ1ヶ月の話となります。

そして脱AppleColorEmojiの決定的な議論が別のPull Req.上で行われていました。

> The next major version of gemoji will focus on removing all embedded images
> and ship only with extraction scripts
>
> <cite>[Offer a choice between different emoji sets by mislav · Pull Request #72 · github/gemoji](https://github.com/github/gemoji/pull/72)</cite>

要約すると、gemojiの次期メジャーバージョンでは、リポジトリからAppleColorEmojiの画像を削除して、Emojiフォントから画像を抽出するスクリプトのみを残すと決められました。リポジトリに残されるのはUnicodeとして定められていないEmoji（:octocat: や :trollface: など）が残されます。

Web上では何が使われるか
-----------------------

現在はOSを検知して、OSにインストールされているEmojiが使用されているようです。GitHubのWebページのコードを少し拝見すると、Emojiは次のタグで埋め込まれていました。

```html
<g-emoji alias="bathtub" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f6c1.png" ios-version="6.0">
```

ここで注目したいのは、`fallback-src`属性です。システムのEmojiを検知できない時、AppleColorEmojiをフォールバック用のリンクに用意しているみたいです。gemojiリポジトリの動きを見ると、こちらもそのうちオープンなEmojiを使用するのでしょうか？

最近はオープンなEmojiがたくさんあるので、いい時代になりましたね。
