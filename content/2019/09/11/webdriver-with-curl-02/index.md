---
title: curlで覚えるWebDriver (2/2)
date: 2019-09-11T21:00:00+09:00
tags: []
---

curlで覚えるWebDriver、第二段です。
前回の記事はこちら。

- [curlで覚えるWebDriver (1/2) - Folioscope][webdriver-with-curl-01]

前回に引き続き、Seleniumのコア機能であるWebDriverをcurlで叩いてみます。
この記事では要素の取得やクリックの送信など、より実践的なAPIを使ってみます。
この記事の最後に、シェルスクリプトによる簡単なE2Eテストの例を紹介します。

## サンプルアプリケーション

まずこの記事で使用するサンプルアプリケーションを作ります。
以下のHTMLはボタンを押すと画面上の数値が+1されるシンプルなアプリケーションです。
このHTMLを適当な名前で保存します。

```html
<!doctype html>
<html lang="en">
  <body>
    <button id="button">++</button>
    <span id="counter">0</span>

    <script>
      document.querySelector("#button").onclick = () => {
        let span = document.querySelector("#counter");
        let num = parseInt(span.textContent, 10)
        if (isNaN(num)) {
          num = 0;
        }
        span.textContent = (num + 1).toString();
      };
    </script>
  </body>
</html>
```

## curlでブラウザのE2Eテストを実行する

このアプリケーションのテスト仕様を考えてみます。
以下のような手順でテストをするとします。

1. 現在表示されている数値をNとする。
1. ボタンをクリックする。
1. 画面上に表示される数値がN+1になっている。

これをWebDriverで自動テストするには、以下のステップで実行します。

1. WebDriverのセッションを作成する。
1. ページを開く
1. 画面上の`#counter`要素を取得して、それを数値Nとする。
1. 画面上の`#button`要素をクリックする
1. 画面上の`#counter`要素を取得して、手順2.で取得した値N+1になってることを確認。

テストをスタートする前に予めgeckodriverまたはchromedriverを起動しておきます。
この記事では4444ポートで起動してると仮定します。

### セッションを作成

まずブラウザのセションを作成します。
セッションの作成は[`POST /sesion`][new-session-0]を使います。

```sh
curl -sSL -XPOST -H'Content-Type: application/json' -d '{ "capabilities": {} }' localhost:4444/session
```

レスポンスにセッションIDが返ってきます。

```json
{
  "value": {
    "sessionId": "2c4a9b35-52b5-42d7-a27c-029582d6131e",
    "capabilities": {
      // ......
    }
  }
}

```

### ページを開く

作成されたセッションは空のページが開かれたブラウザが起動します。
任意のURLを開くには[`POST /session/{session id}/url`][navigate-to]を使います。

*session id*はセッション作成時に返されたセッションIDです。
URLはJSONボディの`"url"`フィールドに指定します。
`"url"`フィールドには`http://` (`https://`) で始まるURLや、ローカルファイルなら `file://` でパスを指定できます。
先程保存したHTMLへのパスを指定します。

```sh
curl -XPOST -H'Content-Type: application/json' \
  -d'{ "url": "file:///path/to/index.html" }' \
  localhost:4444/session/2c4a9b35-52b5-42d7-a27c-029582d6131e/url
```

### 現在のカウンタの値を取得する

要素が含むテキストコンテンツを取得するには[`GET /session/{session id}/element/{element id}/text`][get-element-text]を使用します。
このAPIを呼び出すには予め要素のIDを知る必要があります。

要素のIDを取得するには、[`POST /session/{session id}/element`][find-element]や[`POST /session/{session id}/elements`][find-elements]を呼び出します。
これらのAPIは、CSSセレクタやタグ名、XPathなどから要素を探して、その要素IDを返します。

CSSセレクタで要素を探すには、以下のようなリクエストを投げます。
リクエストボディのJSONに、`"using": "css selector"` を指定して、 `"value"` にCSSセレクタを指定します。

```sh
curl -XPOST -H'Content-Type: application/json' \
  -d'{ "using": "css selector", "value": "#counter" }' \
  localhost:4444/session/2c4a9b35-52b5-42d7-a27c-029582d6131e/element
```

```json
{
  "value": {
    "element-6066-11e4-a52e-4f735466cecf": "ae2ae378-45c6-438a-9a54-d258ea124690"
  }
}
```

`"value"`のオブジェクトのキーは *web element identifier* と呼ばれ、 `"element-6066-11e4-a52e-4f735466cecf"` という固定値です。
オブジェクトのバリューが *web element reference* と呼ばれ、一意なID (UUID) が割り当てらます。
要素を操作するAPIはこのUUIDを指定します（APIの *element id* に *web element reference* を指定しして、 *web element identifier* は使わない）。


取得した*web element reference* の値から、`GET /session/{session id}/element/{element id}/text` でテキストコンテンツを取得するには以下のようなリクエストを投げます。

```sh
curl localhost:4444/session/0395c9e9-4582-4a3f-965d-15b26eb0b68d/element/85eed002-2d05-4a52-815f-95b9af9d628d/text
```

```json
{
  "value": "0"
}
```

### ボタンをクリックする

要素ののクリックは [`POST /session/{session id}/element/{element id}/click`][element-click] を使用します。
*element id* は先ほどと同じ方法で取得した要素のUUIDです。

まずはボタン要素のUUIDを取得します。

```sh
curl -XPOST -H'Content-Type: application/json' \
  -d'{ "using": "css selector", "value": "#button" }' \
  localhost:4444/session/2c4a9b35-52b5-42d7-a27c-029582d6131e/element
```

```json
{
  "value": {
    "element-6066-11e4-a52e-4f735466cecf": "0a812a33-b041-4627-b5ae-54ed4bc5c918"
  }
}
```

そして取得した要素のUUIDを使い、click APIを使います。
リクエストボディは空JSONです。

```sh
curl -XPOST -H'Content-Type: application/json' \
  -d'{}' \
  localhost:4444/session/2c4a9b35-52b5-42d7-a27c-029582d6131e/element/0a812a33-b041-4627-b5ae-54ed4bc5c918/click
```

Webの画面上でカウンタが+1されるはずです。

再びカウンタの値を取得して、それが期待する結果 (1) になってればテストはパスします。

## テストを自動化する

ここまでの手順を簡単なシェルスクリプトを使って実装してみます。
以下のシェルスクリプトはボタンを1回クリックして、カウンタの値が+1されてるかをチェックします。

geckodriverとchromedriverの両方で動作確認はしてあります。
ポート4444固定なので、chromedriverの場合は`--port=4444`を指定してください。

```sh
#!/bin/sh

PORT=4444
TARGET_HTML="file:///path/to/index.html"

create_session() {
  curl -sSL -XPOST -H'Content-Type: application/json' \
      -d '{ "capabilities": {} }' "localhost:${PORT}/session" \
    | jq -r '.value.sessionId'
}

close_session() {
  session_id=$1
  curl -sSL -o/dev/null -XDELETE "localhost:${PORT}/session/${session_id}"
}

navigate_to() {
  session_id=$1
  url=$2
  jq -n --arg url "$url" '{ "url": $url }' \
    | curl -sSL -o/dev/null -XPOST -H'Content-Type: application/json' \
          -d@- "localhost:${PORT}/session/${session_id}/url"
}

get_element_by_css() {
  session_id=$1
  selector=$2
  jq -n --arg selector "$selector" '{ "using": "css selector", "value": $selector }' \
    | curl -sSL -XPOST -H'Content-Type: application/json' -d@- \
          "localhost:${PORT}/session/${session_id}/element" \
    | jq -r '.value["element-6066-11e4-a52e-4f735466cecf"]'
}

click_element() {
  session_id=$1
  element_id=$2
  curl -sSL -o/dev/null -XPOST -H'Content-Type: application/json' \
      -d'{}' "localhost:${PORT}/session/${session_id}/element/${element_id}/click"
}

get_element_text() {
  session_id=$1
  element_id=$2
  curl -sSL "localhost:${PORT}/session/${session_id}/element/${element_id}/text" \
    | jq -r '.value'
}

session_id=$(create_session)

navigate_to "$session_id" "$TARGET_HTML"
counter_element=$(get_element_by_css "$session_id" "#counter")
button_element=$(get_element_by_css "$session_id" "#button")

current_text=$(get_element_text "$session_id" "$counter_element")
click_element "$session_id" "$button_element"
new_text=$(get_element_text "$session_id" "$counter_element")

close_session "$session_id"

if [ "$new_text" -ne "$((current_text + 1))" ]; then
  echo >&2 "Assertion failed: $new_text != $current_text + 1"
fi
echo >&2 "PASS"

```

## まとめ

前回に引き続き「curlで覚えるWebDriver」という記事を書きました。
今回はより実践的なWebアプリケーションのテスト方法を記述してます。
これを各言語のクライアントライブラリとして実装したのがSeleniumになります。

Vim VixenもE2Eテストの自動化にWebDriverをりようしてます。
アドオンのロードはFirefoxのCapabilityを設定してます。
その仕組みを現在1つのライブラリとして書き直してるので、また（機会があれば）紹介したいと思います。

## 参考

- [Selenium Documentation](https://www.seleniumhq.org/docs/index.jsp)
- [Introducing WebDriver | Google Open Source Blog](https://opensource.googleblog.com/2009/05/introducing-webdriver.html)
- [ChromeDriver - WebDriver for Chrome](https://chromedriver.chromium.org/)
- [geckodriver &mdash; Mozilla Source Tree Docs 71.0a1 documentation](https://firefox-source-docs.mozilla.org/testing/geckodriver/index.html)

[webdriver-with-curl-01]: https://i-beam.org/2019/09/08/webdriver-with-curl-01/
[new-session-0]: https://w3c.github.io/webdriver/#new-session-0
[navigate-to]: https://w3c.github.io/webdriver/#navigate-to
[get-element-text]: https://w3c.github.io/webdriver/#get-element-text
[find-element]: https://w3c.github.io/webdriver/#find-element
[find-elements]: https://w3c.github.io/webdriver/#find-elements
[element-click]: https://w3c.github.io/webdriver/#element-click
