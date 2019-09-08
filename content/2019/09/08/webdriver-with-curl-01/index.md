---
title: curlで覚えるWebDriver (1/2)
date: 2019-09-08T22:00:00+09:00
tags: []
---

WebDriverについて調べる機会があったので簡単にまとめました。
この記事ではcurlを使って、WebDriverによるブラウザ操作をしてみます。

## WebDriverとSeleniumの歴史

Seleniumは現在最も広く使われている、Webブラウザの自動化・テストフレームワークです。
多くの言語をサポートしており、JavaやC#などの言語から、Webページを開いたり要素の検証ができます。
そのためWebサービスのEnd-to-end (E2E) テストの自動化で主に利用されています。

[Selenium 1 (Selenium RC)][selenium rc] と呼ばれていた時代は、ブラウザを操作するためにSelenium CoreというJavaScriptをブラウザ上でロードしてました。
しかしブラウザのセキュリティ強化により、Selenium CoreのJavaScript実行が難しくなったため、モダンブラウザではSelenium Coreが動かなくなりました。

SeleniumのヘビーユーザーだったGoogleは、Selenium Coreとは別のアプローチをとるため、WebDriverというプロジェクトをスタートしました。
WebDriverはJavaScriptではなく、各ブラウザが実装する *ドライバ* によってブラウザを操作します。
クライアントは標準化されたAPIによってブラウザを制御できます。

のちにWebDriverプロジェクトとSeleniumプロジェクトは統合され、それが現在のSelenium 2.0になります。
Selenium 2.0はSelenium RCの問題を解決するだけでなく、より洗練されたAPIを提供します。
現在はSelenium 2.0がE2Eテストのフレームワークのデファクトスタンダードになっています。

## WebDriverの仕様と実装

WebDriver APIはJSONベースのREST APIです。
WebDriver APIの仕様は、W3Cで仕様化が進められています。

- [WebDriver - W3C Recommendation](https://www.w3.org/TR/webdriver/)

それぞれのブラウザドライバは、この仕様に則ったAPIを提供します。
ChromeDriver (Google Chrome/Chromium)、FirefoxDriver (Firefox)、InternetExplorerDriver (Internet Explorer)、SafariDriver (Safari)、PhantomJSDriver(Phantom JS) などのブラウザドライバが存在します。
WebDriver APIを叩くためのクラスがSelenium本体に組み込まれてますが、curlなどのHTTPクライアントからも利用できます。

ドライバが実際どのようにブラウザを操作するかは、それぞれのブラウザの実装に依存します。
たとえばgeckodriverは[Marionette remote protocol][marionette]とよばれるTCPベースのプロトコルでFirefoxを制御します。
しかしエンドユーザはブラウザ固有のプロトコルを知らずとも、WebDriver APIさえ使えば、おなじインターフェイスでFirefoxやChromiumを操作できます。

## curlでWebDriverを操作する

前置きが長くなりましたが、本記事の目的であるcurlでWebDriverを操作してみます。

### WebDriverを起動する

この記事ではFirefox用のgeckodriverと、Chrome用のchromedriverを使用します。
ダウンロードはそれぞれ以下のリンクからできます。

- [geckodriver](https://github.com/mozilla/geckodriver/releases/tag/v0.24.0)
- [chromedriver](https://chromedriver.chromium.org/downloads)

それぞれ特にオプションなしで起動します。

```sh
# Firefox
geckodriver

# Chromium/Google Chrome
chromedriver
```

geckodriverはデフォルトポートは4444、chromedriverはデフォルトポートは9515で起動します。

現在のドライバの状態は[`GET /status`][dfn-status]で取得できます。

```sh
# geckodriver
curl -sSL localhost:4444/status

# chromedriver
curl -sSL localhost:9515/status
```

レスポンスはJSONで返されます。
ドライバが利用可能になってると `"ready": true` がセットされます。
またドライバ固有のメッセージが `"message"` に含まれます。
以下はgeckodriverが返すJSONの例です。

```json
{
  "value": {
    "message": "",
    "ready": true
  }
}
```

### セッションを作成する

起動されるブラウザは、ドライバ内でセッションという形で管理されます。
ブラウザを起動するには[`POST /sesion`][dfn-new-sessions]からセッションを作成します。

```sh
# geckodriver
curl -sSL -XPOST -H'Content-Type: application/json' -d '{}' localhost:4444/session

# chromedriver
curl -sSL -XPOST -H'Content-Type: application/json' -d '{ "capabilities": {} }' localhost:9515/session
```

`"capabilities"`フィールドはブラウザのオプションを指定します。
指定可能なCapabilitiesの一部は[標準化][capabilities]されてます。
またブラウザ固有のCapabilitiesもあり、geckodriverとchromedriverのCapabilitiesはそれぞれ以下のドキュメントから確認できます。

- [geckodriver](https://firefox-source-docs.mozilla.org/testing/geckodriver/Capabilities.html)
- [chromedriver](https://chromedriver.chromium.org/capabilities)

作成されたセッションの情報はJSONで返され、セッションの情報は`"value"`フィールドに格納されます。
各セッションには一意のセッションIDが付与され、`"sessionId"`フィールドから確認できます。
また起動したブラウザのCapabilitiesは`"capabilities"`フィールドにセットされてます。
以下はgeckodriverが返すJSONの例です。

```json
{
  "value": {
    "sessionId": "75765ef8-73e3-449d-920d-d48bd3838a35",
    "capabilities": {
      "acceptInsecureCerts": false,
      "browserName": "firefox",
      "browserVersion": "70.0",
      "moz:accessibilityChecks": false,
      "moz:buildID": "20190905174512",
      "moz:geckodriverVersion": "0.24.0",
      "moz:headless": false,
      "moz:processID": 22557,
      "moz:profile": "/tmp/rust_mozprofile.2dpoXOgM4Lb5",
      "moz:shutdownTimeout": 60000,
      "moz:useNonSpecCompliantPointerOrigin": false,
      "moz:webdriverClick": true,
      "pageLoadStrategy": "normal",
      "platformName": "linux",
      "platformVersion": "5.2.11-arch1-1-ARCH",
      "rotatable": false,
      "setWindowRect": true,
      "strictFileInteractability": false,
      "timeouts": {
        "implicit": 0,
        "pageLoad": 300000,
        "script": 30000
      },
      "unhandledPromptBehavior": "dismiss and notify"
    }
  }
}
```

### セッションを終了する

ブラウザを終了するには、[`DELETE /session/{session id}`][dfn-delete-session]からセッションを破棄します。
*session id* は `POST /session` のレスポンスに含まれるセッションIDです。

```sh
# geckodriver
curl -XDELETE localhost:4444/session/8985eb04-54a7-4a43-b847-4c7d4423a00b

# chromedriver
curl -XDELETE localhost:9515/session/814aefbd9b2d0605f6203a1a3336c935
```

## まとめ

WebDriverは現代のE2Eテスト自動化フレームワークのデファクトスタンダードになってます。
Vim VixenでもE2Eテストを自動化するために、WebDriverを利用してます。
その中身はシンプルなREST APIで、curlからもブラウザを制禦できます。

この記事ではセッションの作成・削除まで説明しました。
次回はページを開いたりユーザー操作（クリックやキー入力）を発火し、そして要素の検証までをcurlで体験したいと思います。

## 参考

- [Selenium Documentation](https://www.seleniumhq.org/docs/index.jsp)
- [Introducing WebDriver | Google Open Source Blog](https://opensource.googleblog.com/2009/05/introducing-webdriver.html)
- [ChromeDriver - WebDriver for Chrome](https://chromedriver.chromium.org/)
- [geckodriver &mdash; Mozilla Source Tree Docs 71.0a1 documentation](https://firefox-source-docs.mozilla.org/testing/geckodriver/index.html)

[dfn-status]: https://w3c.github.io/webdriver/#dfn-status
[dfn-new-sessions]: https://w3c.github.io/webdriver/#dfn-new-sessions
[dfn-delete-session]: https://w3c.github.io/webdriver/#dfn-delete-session
[capabilities]: https://w3c.github.io/webdriver/#capabilities
[selenium rc]: https://www.seleniumhq.org/docs/05_selenium_rc.jsp
[marionette]: https://firefox-source-docs.mozilla.org/testing/marionette/
[geckodriver]: https://firefox-source-docs.mozilla.org/testing/geckodriver/
[chromedriver]: https://chromedriver.chromium.org/
[geckodriver/#882]: https://github.com/mozilla/geckodriver/issues/882
