---
title: ブラウザテスト自動化のカスタムGitHub Actionsを作った (その2)
date: 2021-01-31T20:30:00+09:00
tags: [GitHub, WebExtensions]
---

[FirefoxをセットアップするGitHub Actions][setup-firefox-article]を先日作りました。
これに加えて、ChromiumとMicrosoft EdgeをセットアップするGitHub Actionsも作りました。

## Firefox

[setup-firefox][]はFirefoxをセットアップするActionです。
`firefox-version` パラメータでインストールするバージョンを指定します。
インストール後、PATHにFirefoxのインストールディレクトリが追加され、指定したバージョンを利用できます。

```yaml
steps:
  - uses: ueokande/setup-firefox@latest
    with:
      firefox-version: '78.3.0esr'

  - run: firefox --version
```

Firefoxのバージョンは、特定のバージョンだけでなく `latest-esr` や `latest-beta` も利用できます。

## Chromium

[setup-chromium][]はChromiumをセットアップするActionです。
`chromium-version` パラメータでインストールするバージョンを、コミットポジション（ソースコードの履歴の位置）で指定します。
インストール後、PATHにChromiumのインストールディレクトリが追加され、指定したバージョンを利用できます。

```yaml
steps:
  - uses: browser-actions/setup-chromium@latest
    with:
      chromium-version: 827102

  - run: chrome --version
```

指定がない場合は最新ビルドをダウンロードします。

## Microsoft Edge

[setup-edge][]はMicrosoft EdgeをセットアップするActionです。
`edge-version` パラメータでインストールするバージョンを、チャンネル名 `stable`、`beta`、`dev` で指定します。
インストール後、PATHにEdgeのインストールディレクトリが追加され、指定したバージョンを利用できます。

```yaml
steps:
  - uses: browser-actions/setup-chromium@latest
    with:
      edge-version: stable

  - name: Print Edge version
    run: (Get-Item (Get-Command msedge).Source).VersionInfo.ProductVersion
```

指定がない場合は最新の `stable` をダウンロードします。

[setup-firefox-article]: /2021/01/05/github-actions/

## 設定例


紹介したGitHub Actionsを使ってクロスブラウザのテストを実行する例を紹介します。
GitHub Actionsのテストマトリックスを使って、Chromium、Firefox、Microsoft Edgeでテストを実行します。

ChromiumおよびMicrosoft Edgeは、Karmaのミドルウェアとインストールされるファイル名が異なるため、それぞれ `CHROMIUM_BIN` と `EDGE_BIN` をテスト実行前に上書きします。

```yaml
jobs:
  build:
    strategy:
      matrix:
        browser: [chromium, firefox, edge]
    runs-on: windows-latest

    steps:
      # ブラウザのインストール
      - uses: browser-actions/setup-firefox@latest
        if: matrix.browser == 'firefox'
        with:
          firefox-version: "84.0"
      - uses: browser-actions/setup-chromium@latest
        if: matrix.browser == 'chromium'
      - uses: browser-actions/setup-edge@latest
        if: matrix.browser == 'edge'

      # テストの実行
      - name: Run tests on Firefox
        if: matrix.browser == 'firefox'
        run: |
          yarn test --browsers=Firefox
      - name: Run test on Chromium
        if: matrix.browser == 'chromium'
        run: |
          $Env:CHROMIUM_BIN = "chrome"
          yarn test --browsers=Chromium
      - name: Run test on Microsoft Edge
        if: matrix.browser == 'edge'
        run: |
          $Env:EDGE_BIN = "msedge.exe"
          yarn test --browsers=Edge
```

テストの全貌は[browser-actions/examples/][]で確認できます。

[browser-actions/examples/]: https://github.com/browser-actions/examples
[setup-firefox]: https://github.com/browser-actions/setup-firefox
[setup-chromium]: https://github.com/browser-actions/setup-chromium
[setup-edge]: https://github.com/browser-actions/setup-edge
