---
title: 「WebExtensionsとテスト」というお話をしてきました
date: 2018-11-07 22:00 JST
---

先日、WebExtensions Meetup #3 が開催され、そこで「WebExtensionsとテスト」というお話をしてきました。
この発表では、 WebExtensionsのテストの方法と、Vim Vixenが取り組んでいることについてお話しました。

- [WebExtensionsとテスト - Speaker Deck](https://speakerdeck.com/ueokande/webextensionstotesuto)

この記事では発表資料をかいつまんで、より詳しく説明してゆきたいとおもいます。
それでははじまりはじまり〜。

## はじめに

<img style='width:420px; display: inline-block' alt='タイトルスライド' src='/2018/11/07/slide-0.png' />
<img style='width:420px; display: inline-block' alt='自己紹介スライド' src='/2018/11/07/slide-1.png' />

まずは自己紹介。
WebExtensions歴は1年ちょいです。
メインで開発してるWebExtensionsは「Vim Vixen」です。

<img style='width:420px; display: inline-block' alt='Vim Vixen' src='/2018/11/07/slide-3.png' />
<img style='width:420px; display: inline-block' alt='Vim Vixenの開発環境' src='/2018/11/07/slide-5.png' />

Vim Vixenの開発をスタートしたきっかけは、XUL製だったVimperatorが使えなくなったからです。
開発を始めて1年が経ち、現在はユーザー数も10,000を超えるほどになりました。

開発的な視点で見てみると、本体コードが5,000行程度、テストコードは3,000行程度の規模感です。
ビルドはBabelを使ってES7をトランスパイルし、webpackでシングルJS化してます。
またCircleCIを使って継続的にlintと、今回お話する**テスト**を実行してます。

## なぜテストを書くのか

Vim Vixenの話をする前に、まずはなぜテストを書く必要があるかをおさらいします。

<img style='width:420px; display: inline-block' alt='なんでテストを書くんだっけ？' src='/2018/11/07/slide-6.png' />
<img style='width:420px; display: inline-block' alt='（理想の）テストピラミッド' src='/2018/11/07/slide-9.png' />

テストの自動化は手動のテストよりも効率的です。
また一般的にテストしやすいコードはメンテしやすいコードでもあります。
継続的にテスト書き続けることで、将来の機能追加やリファクタリングで困らないようにします。
そして試験を自動化することで、リグレッションも早期に発見できるようになります。

Vim VixenではテストをユニットテストとE2Eテストに分類してます。
テストの自動化は、費用対効果が高いユニットテストで多くのテストを網羅するのが理想だと言われてます。

## Vim Vixenのユニットテスト

ここからはVim Vixenの試験自動化で取り組んできたことを説明します。

<img style='width:420px; display: inline-block' alt='Vim Vixenのユニットテスト' src='/2018/11/07/slide-11.png' />

まずテストの実行環境は、テストフレームワークに**Mocha**を、そしてテストランナーに**Karma**をつかってます。
この環境はフロントエンドの技術をそのまま使っています。

<img style='width:420px; display: inline-block' alt='DOMアクセスのテスト' src='/2018/11/07/slide-13.png' />
<img style='width:420px; display: inline-block' alt='利用例' src='/2018/11/07/slide-14.png' />


WebExtensionsのcontent scriptは通常のJavaScript同様、DOMにアクセスすることが多いです。
Vim Vixenではこれらのテストに[karma-html2js-preprocessor][]を使ってます。
このプリプロセッサは、ファイルに保存されてるHTMLを、JavaScriptの文字列としてアクセス可能になります。
テストコードではテスト実行前・実行中にに`document.innerHTML`に上書きして、テストケースをファイルとして管理できます。

<img style='width:420px; display: inline-block' alt='browserオブジェクトのモック' src='/2018/11/07/slide-15.png' />
<img style='width:420px; display: inline-block' alt='利用例' src='/2018/11/07/slide-16.png' />


つづいてWebExtensions APIの `browser` オブジェクトを使ったクラスのテストです。
[webextensions-api-fake][] を使うことで、`browser` オブジェクトをモックできます。
通常WebExtensionsを利用できないJavaScriptのテスト環境でも、擬似的な `browser` オブジェクトを利用できます。

## E2Eテスト

続いてE2Eテストの自動化についてです。

<img style='width:420px; display: inline-block' alt='Vim Vixenのリリースフロー' src='/2018/11/07/slide-18.png' />
<img style='width:420px; display: inline-block' alt='Vim Vixenの試験項目' src='/2018/11/07/slide-19.png' />

まずはVim Vixenのリリースフローの説明です。
Vim Vixenでは書くリリース毎に100以上の試験項目を**手動**で確認して、パスすれば新しいバージョンをリリースしてました。

<img style='width:420px; display: inline-block' alt='E2Eテストの自動化' src='/2018/11/07/slide-20.png' />
<img style='width:420px; display: inline-block' alt='自動化の方針' src='/2018/11/07/slide-21.png' />

しかしその手順をリリース毎に繰り返すのは、コストが高くて退屈な作業です。
そこでVim Vixenでは、E2Eテストの自動化にも取り組んでます。
Vim VixenのE2Eテストを実行するために、テストコードからタブ情報や別タブにキー入力を送れるよう「ambassador」アドオンというのを作成しました。

<img style='width:420px; display: inline-block' alt='ambassadorアドオン (1/2)' src='/2018/11/07/slide-23.png' />
<img style='width:420px; display: inline-block' alt='ambassadorアドオン (2/2)' src='/2018/11/07/slide-24.png' />

テストコードから `window.postMessage()` でメッセージを送ると、ambassadorアドオンがbackground scriptに問い合わせたり、別タブのambassadorアドオンのcontent scriptと通信します。

<img style='width:420px; display: inline-block' alt='ambassadorアドオンの実行' src='/2018/11/07/slide-25.png' />

E2E試験をKarmaで実施するために、web-extのKarmaテストランナーを自作し、web-extにも少し手を加えました。

<img style='width:420px; display: inline-block' alt='E2Eテストのテストケース例' src='/2018/11/07/slide-26.png' />

テストケースはES7のawait/asyncを使うことで、手続き的にユーザー操作を記述することもできました。
ambassadorアドオンへのメッセージ送信は、クライアントライブラリとしてラップしています。

## まとめ

E2Eの現実として、実際はは45/163テストケースしか自動できておらず、今でも100を超えるテストケースは手動で行ってます。

<img style='width:420px; display: inline-block' alt='Vim Vixenのこれから' src='/2018/11/07/slide-31.png' />
<img style='width:420px; display: inline-block' alt='まどめ' src='/2018/11/07/slide-32.png' />


E2Eテストにも限界があるので、手動の試験を減らすためにも、
ユニットテストの配分をより大きくして、理想のテストピラミッドに近づけていこうと思います。
またCIだけでなくCDにも力を入れたいと思います。

この発表では、Vim Vixenで取り組んできたWebExtensionsのテストについてお話しました。
今後もVim Vixenの開発は続けていくので、引き続き応援お願いします！


[karma-html2js-preprocessor]: https://github.com/karma-runner/karma-html2js-preprocessor
[webextensions-api-fake]: https://github.com/webexts/webextensions-api-fake
