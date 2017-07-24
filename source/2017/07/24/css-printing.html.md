---
title: CSSでPDF出力をいい感じに設定する
date: 2017-07-24 21:00 JST
---

CSSには印刷のスタイルを指定できるルール・プロパティが用意されています。
そしてChromiumやGoogle Chromeは標準でPDF出力ができます。
つまり厄介なPDFファイル作成をCSSで簡単にできるようになります。
この記事は、CSSでいい感じにPDF出力する例を説明します。

サンプルはCodePenで公開しています。  
[https://codepen.io/ueokande/pen/yoBwrq](https://codepen.io/ueokande/pen/yoBwrq)

CSSの印刷サポート
-----------------

CSSには、以下のような印刷の設定ができるルール・プロパティが用意されています。

- `@media print { ... }`: このルール内に記述されたCSSは、印刷時のみ適用される。
- `@page { ... }`: 印刷時のページサイズやマージンを指定する。
- `page-break-before`プロパティ: 要素の直前で改ページを制御する
- `page-break-after`プロパティ: 要素の直後で改ページを制御する
- `page-break-inside`プロパティ: 要素の中で改ページを制御する
- `-webkit-print-color-adjust`プロパティ ...要素の背景色、背景画像を印刷するかを指定する

例: スライドを出力
------------------

プレゼンテーションのスライドを例にします。

まず、こんな感じのHTMLを用意します。


```html
<section>
  <h1>What is Lorem Ipsum?</h1>
  <ul>
    <li>Lorem Ipsum is simply dummy text of the printing and typesetting industry.</li>
    <li>Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
        when an unknown printer took a galley of type and scrambled it to make a type specimen book.</li>
  </ul>
</section>
<section>...</section>
<section>...</section>
<section>...</section>
```

そしてCSSで`section`のスタイルを適用します。

```css
section {
  width: 640px;
  height: 480px;
  display: inline-block;
  margin: 12px;
  box-shadow: 0 0 4px black;
  box-sizing: border-box;
}
```

するとこんな感じの、スライドのような感じで表示されます。

[<img style='min-width:800px; max-width:100%; height:auto' alt='Browser preview' src='/2017/07/24/browser.png' >](browser.png)

これで1ページ1`section`で出力できるようにCSSを指定します。
適用したCSSは次のような感じです。

```css
@media print {
  @page {
    size: 640px 480px;
    margin: 0;
  }

  * {
    -webkit-print-color-adjust: exact;
  }

  body {
    margin: 0;
    padding: 0;
  }

  section {
    margin: 0;
    box-shadow: none;
    page-break-before: always;
  }
}
```

まず`@page`ルールで、印刷時の余白を0にして、ページサイズを`section`と一致させます。
`-webkit-print-color-adjust: exact` で、印刷時に背景色・背景画像を出力します。
`section`に`page-break-before: always`を指定して、`section`の直前で改ページするようにします。
これは、もし`section`より大きなページで出力した場合でも、各`section`ごとに改ページされるようにします。

Chromium/Google Chromiumで印刷ダイアログを表示して、1ページ1`section`のようにプレビューされればOKです。

[<img style='width:768px; height:auto' alt='Print preview' src='/2017/07/24/print.png' >](print.png)
