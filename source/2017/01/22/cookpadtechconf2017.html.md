---
title: Cookpad TechConf 2017に行ってきた

date: 2017-01-22 09:00 JST
---

[Cookpad TechConf 2017](https://techconf.cookpad.com/2017/)に行ってきました。
発表と感想を雑にまとめました。

[発表資料・動画](https://techconf.cookpad.com/2017/presentation_materials.html)が後日公開されるので、この記事を読むよりもそちらを呼んだほうが良い気がします。

READMORE

Cookpad under a microscope
--------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="3388fa78b9454c68b4261e2d706e5830" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- Cookpadは「レシピを探す人」「レシピを投稿する人」のビジネスが確立
- イケイケベンチャー感あるが今年で**21年**
- オープンソースのタダ乗りをしない、 コミュニティへの貢献がビジネスも成長させる
- Rubyコミッタ**笹田**さん、cookpadに入社

Go Global
---------

<div style='width:480px; height:320px; margin: 16px 0 48px'>
<script async class="speakerdeck-embed" data-id="77d57b0a83d8475998ed60608bd27fe4" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- 海外新種は多言語化のみではない、現地の生活にいち早く馴染めるかが鍵
- 国によって当たり前品質(must-be quality)と魅力的品質(attractive quality)は異なる
- 地道な努力がグローバル進出への実を結んでいるんだと思った。

Building infrastructure for our global service
----------------------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="1b1369b6170a4310856f58ce5c318964" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- 世界中からアクセスされるCookpadの構成
- イスラムのラマダンでアクセスがやばい
- 円滑なDevOpsできる環境づくりも進んでいる

サービス開発におけるデザインの取り組み方
----------------------------------------

<div style='width:480px; height:320px; margin: 16px 0 48px'>
<script async class="speakerdeck-embed" data-id="cb043cbf8e2148f0a9e3401c77edd131" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- デザイナの仕事≠画面のデザイン
- 価値検証のためのプロトタイピング
- 実データを使ってプロトタイプを作る

モバイルアプリのABテスト
------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="94de0faa55224effa75687794b810e88" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- モバイル向けABテストフレームワークをを内製
- モバイルはWebとはまた違う課題がある
- その画題を技術で埋めている感じがした

チームでプロダクト開発をするための取り組み
------------------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="e814d5adbd3d4b2cba70340cfcfb1e6a" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- チームのパフォーマンス・成果を最大化するためのマネジメントとは
- *チームメンバーからの信頼を得ること*を根底に取り組む
- 信頼を得るのも一朝一夕でできることではないので、発表者のカリスマ性を感じた

より良い検索体験のための情報設計とプロトタイピング
--------------------------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="a4d0e09b0b2a4aadb97137fe7040c14b" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- 機能と体験は表裏一体
- 目指す体験を明確にし、それを得るに至る具体的なシナリオと必要な機能を選定・洗礼
- 検索も、どんな流れで目的を達成できるか
- 機能ごとに部署が出来上がるのは面白い

組織全体でGitHubを使ようになるまで
-----------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="2d554c99b66b4d9eb3f326f91e6decb7" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- エンジニア以外の人たちにも、GitHubでコミュニケーション
- 非エンジニアのハードルを下げる取り組みなど
- GitHubが最適な答えかは疑問で、登壇者もそう発言していた。
- それでも情報共有基盤を1つにまとめることで、煩雑なコミュニケーションが減って良い

快適なサービス開発を支える技術
------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="142e2fa620d8429dac0a42362e300828" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- マイクロサービスのためのツールたち
- Slack botでデプロイ
- Zabbixで監視、異常時はSlackに通知、Twilioで電話
- 生産性・開発サイクルを最大限にしている感じがした
- 1日に何回も安定・安心してデプロイできる仕組みすごい

Real World Machine Learning
---------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="9edfefe1da3f4b4c8336773bc4c8aba5" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- Cookpadの機械学習利用するまでの道のり
- AWS上のGPUクラスタの環境構築も自動化
- 2016年7月に研究開発部発足、同年10月にアプリリリース
- 環境構築・改善はWebエンジニアリングと通ずる
- 「研究開発部」という名前だが、物を作って3ヶ月でアプリリリースできるのすごい

行動ログでプロダクトを改善するには
----------------------------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="28511c6020da429db65645b4b17a2bb1" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- ログからユーザをモニタ、そしてエンパワー
- DBもログも一箇所のDWHにあるので、SQLで横断的にクエリがかける
- ディレクターもデータ・ログに興味があるのでどんどんクエリを叩く
- そういえばSQLの関数全然知らないや

Cookpad awakens
---------------

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="c4b35580cd60499aaaf571909c9484ab" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
</div>

- めっちゃ環境が進歩しており、ツールをめっちゃアウトプットしてる
- 不安定なスポットインスタンスも平然と安定稼働させるのすごい
- 今年の活動にもさらなる期待

おわりに
--------

最後に雑な感想を

- 社員たちがOSS化へのモチベーションが高い、そしてできる環境が揃っているのが良い
- 1年目からガンガン登壇・活躍しているのもすごい
- 明言してる人はいなかったが、20年の歴史の賜物なんだなーと思った
- 帰ってからストリームの録画を見てみたが、見やすくて良い

