---
title: TypeScriptに移行して気づいた10の事実
date: 2019-05-30T21:00:00+09:00
tags: [Vim Vixen, TypeScript]
---

ついにVim Vixenを[TypeScriptに移行しました](https://github.com/ueokande/vim-vixen/pull/578)。
今まで強がりでECMAScriptで書いてたのですが、静的型付き言語の便利さに負けてついに移行しました。
その時に新しい発見がいくつかあったので簡単にまとめます。

エコシステムが十分に育っている
---------------
TypeScriptに移行するのなら、トランスパイラ本体だけではなく周辺ライブラリのサポートも必要です。
たとえばVim VixenではWebpackでのビルドやLinterのチェックをしてます。
また使ってるライブラリの型定義もほしいです。
それらTypeScript以外とのエコシステムの成熟度が、今回の移行の鍵でした。

結論として無事移行できました。
Vim Vixenのライブラリ利用状況は以下のようになりました。

- ビルド: Webpack + ts-loader
- Linter: ESLint + @typescript-eslint/eslint-plugin
- テスト: karma-webpack + mocha/chai

若干@typescript-eslint/eslint-pluginで不具合がありますが、現在絶賛開発中なので将来にも期待できます。

型アノテーションをつけるだけで移行完了、ではない
-----------------

TypeScriptはECMAScript（ECMAScript 2015）互換の言語なので、当初はとりあえず型アノテーションを付けて終わらせようと思ってました。
しかし実際は気付かなかった記述ミスや余分なパラメータがありました。
TypeScriptの型チェックがパスするまで、それらを削除したり`undefined`チェックを追加しました。

予想してたよりもTypeScript移行に時間がかかりました。
結局、型アノテーションをつけるだけでは終わらなかったのですが、未然に多くのバグを防ぐことができたので良しとします。

Optionalなプロパティに気づける
-------------------

WebExtensions APIの型定義に[web-ext-types](https://github.com/kelseasy/web-ext-types)を使いました。
型定義を使うと、APIがOptional (`undefined`になりうる) プロパティも事前に検知できてバグを未然に発見できます。

例えば以下のコードは、現在のタブにメッセージを送るコードです。
このコードはトランスパイル時にエラーが出ます。

```typescript
let tabs = await browser.tabs.get({ active: true });
browser.tabs.sendMessage(tabs[0].id, {
  type: 'greeting',
  text: 'Hello, world!'
});
```

なぜなら`Tab.id` フィールドはOptionalだからです。
`browser.tabs.sendMessage()` の第1引数は`number`なので、Optionalなフィールドは渡せません。

```console
index.ts:3:26 - error TS2345: Argument of type 'number | undefined' is not assignable to parameter of type 'number'.
  Type 'undefined' is not assignable to type 'number'.

3 browser.tabs.sendMessage(tabs[0].id, {
                           ~~~~~~~~~~
```

解決するには`undefined`チェックするか、

```typescript
let tabs = await browser.tabs.query({ active: true });
let id = tabs[0].id;
if (typeof id === 'undefined') {
  return;
}
browser.tabs.sendMessage(id, {
  type: 'greeting',
  text: 'Hello, world!'
});
```

`undefined`ではないといい切れるなら`!!`を付けます。

```typescript
let tabs = await browser.tabs.query({ active: true });
browser.tabs.sendMessage(tabs[0].id!!, {
  type: 'greeting',
  text: 'Hello, world!'
});
```

仕様変更する場合がある
-----------

先程TypeScriptはOptionalな型に気づけて良いと書きました。
しかし何でもかんでも無条件に`undefined`チェックを記述できるとは限りません。
例えば先程の`Tab.id`ですが、それを別のメソッドに渡すとします。

```javascript
// 移行前
processTab(tabs[0].id);
```

```typescript
// 移行後、undefinedチェックを追加。
let id = tabs[0].id;
if (typeof id === 'undefined') {
  return;
}
processTab(id);
```

一見TypeScriptの方が堅牢に見えて良いコードに思えます。
しかし前者と後者は振る舞いが異なります。

移行前のコードに不具合があるかも知れませんが、もしかすると呼び出し側が外発生を期待してるかも知れません。
どちらにせよ、むやみに`undefined`チェックを挿入すると、意図しない仕様変更をする可能性があるので気をつける必要ああります。

* * *

まだまだあった気がするけど収まりが悪いのでこのへんで。
思い出したらまた書きます....

