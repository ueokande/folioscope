---
title: Vim Vixenの簡単な使い方
date: 2017-11-13T22:00:00+09:00
tags: [Vim Vixen, WebExtensions]
---

![Screen shot 1](screenshot1.png)

本日Vim Vixen 0.5をリリースしました。  
[Vim Vixen - Add-ons for Firefox](https://addons.mozilla.org/en-US/firefox/addon/vim-vixen/)

0.5ではページ内検索も備わって、いよいよまともに使えるプラグインとなってきました。
もちろんこれからも開発は続いてゆきます。

![github][ueokande/vim-vixen]

MUSTな機能は大体実装できたので、ここで日本語による使い方の解説をしたいとおもいます。

## 基本的な使い方

ここでは基本的なキーマップを紹介します。
キーマップは`about:addons`でJSON形式で指定します。

#### スクロール

- <kbd>j</kbd>, <kbd>k</kbd>, <kbd>h</kbd>, <kbd>l</kbd>: 垂直方向、水平方向にスクロール
- <kbd>Ctrl</kbd>+<kbd>U</kbd>, <kbd>Ctrl</kbd>+<kbd>D</kbd>: 半ページスクロール
- <kbd>Ctrl</kbd>+<kbd>B</kbd>, <kbd>Ctrl</kbd>+<kbd>F</kbd>: 1ページ分スクロール
- <kbd>0</kbd>, <kbd>$</kbd>: 最左、最右にスクロール
- <kbd>g</kbd><kbd>g</kbd>, <kbd>G</kbd>: ページの先頭、末端にスクロール

#### タブ操作

- <kbd>d</kbd>: 現在のタブを削除
- <kbd>u</kbd>: 閉じたタブを開く
- <kbd>K</kbd>, <kbd>J</kbd>: 次、前のタブを選択
- <kbd>g0</kbd>, <kbd>g$</kbd>: 最初、最後のタブを選択
- <kbd>r</kbd>: リロード
- <kbd>R</kbd>: スーパーリロード
- <kbd>zp</kbd>: 現在のタブをピン留め
- <kbd>zd</kbd>: 現在のタブを複製

#### コンソール

- <kbd>:</kbd>: コンソールを開く
- <kbd>o</kbd>, <kbd>t</kbd>, <kbd>w</kbd>: それぞれ、現在のタブ、新しいタブ、新しいウィンドウを開く
- <kbd>O</kbd>, <kbd>T</kbd>, <kbd>W</kbd>: それぞれ、<kbd>o</kbd>, <kbd>t</kbd>, <kbd>w</kbd> と似ているが現在のURLがコンソールにセットされる
- <kbd>b</kbd>: タブの選択

### ナビゲーション

- <kbd>f</kbd>: リンクのフォローを開始。ヒントによってリンクを選択
- <kbd>F</kbd>: リンクのフォローを開始。選択したリンクを新しいタブに開く
- <kbd>H</kbd>, <kbd>L</kbd>: 履歴を戻る、進む
- <kbd>[</kbd><kbd>[</kbd>, <kbd>]</kbd><kbd>]</kbd>: ページ内の「前」「次」のリンクを開く
- <kbd>g</kbd><kbd>u</kbd>: 親ディレクトリを開く
- <kbd>g</kbd><kbd>U</kbd>: ルートディレクトリを開く

#### その他

- <kbd>z</kbd><kbd>i</kbd>, <kbd>z</kbd><kbd>o</kbd>: ズームイン、ズームアウト
- <kbd>z</kbd><kbd>z</kbd>: ズームレベルをデフォルトに戻す
- <kbd>y</kbd>: 現在のタブのURLをコピー
- <kbd>Shift</kbd>+<kbd>Esc</kbd>: プラグインを一時的に無効化

### コンソールのコマンド

画面下部のコンソールは、VimのEXコマンドのようにコマンドを入力できます。
<kbd>:</kbd> で空のコンソールを開いたり、<kbd>o</kbd>, <kbd>t</kbd>, <kbd>w</kbd> で予め入力されたコンソールを開きます。
以下はコンソールのコマンドの紹介です。

#### `open` コマンド

`open` コマンドはURLを開いたり、キーワードで検索したりできます。
例えば以下の例では、GitHubのページをURLで指定します。

```
:open http://github.com/ueokande
```

また次の例は、検索エンジン（デフォルトではGoogle）で検索します。

```
:open How to contribute to Vim-Vixen
```

検索エンジンも指定できます。

```
:open yahoo How to contribute to Vim-Vixen
```

検索エンジンは設定可能です。詳しくは「検索エンジン」の節を読んでください。

#### `tabopen` コマンド

新しいタブにページを開いたり検索結果を開きます。

#### `winopen` コマンド

新しいウィンドウにページを開いたり検索結果を開きます。

#### `:buffer` command

タブを切り替えます。

### 検索エンジン

Vim Vixenは複数の検索エンジンをサポートしています。
検索エンジンの設定は、JSON形式で指定します。

検索エンジンはキーワードと、検索エンジンのURLの対で指定して、URLは検索キーワードに置換される{}-プレースホルダーを含める必要があります。
以下はデフォルトの検索エンジンの設定です。

```json
{
  "search": {
    "default": "google",
    "engines": {
      "google": "https://google.com/search?q={}",
      "yahoo": "https://search.yahoo.com/search?p={}",
      "bing": "https://www.bing.com/search?q={}",
      "duckduckgo": "https://duckduckgo.com/?q={}",
      "twitter": "https://twitter.com/search?q={}",
      "wikipedia": "https://en.wikipedia.org/w/index.php?search={}"
    }
  }
}
```

### ブラックリスト

一部のURLでプラグインを無効化するために、Vim Vixenはブラックリストをサポートしています。
ブラックリストの設定では、JSON形式で指定します。
たとえばSlackの任意の部屋で無効化したい場合は`"*.slack.com"` を記述します。
また`"example.com/mail/*"`のようにパスの指定も可能です。

```json
{
  "blacklist": [
    "*.slack.com",
    "example.com/mail/*"
  ]
}
```

無効化されたプラグインは、<kbd>Shift</kbd>+<kbd>Esc</kbd>キーで再び有効化できます。

### 最後に

ここの情報は古くなる可能性があります。
新しい情報は常にGitHubを見るようにしてください。

![github][ueokande/vim-vixen]
