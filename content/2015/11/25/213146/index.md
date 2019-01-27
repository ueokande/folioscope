---
title: Travis CI がテストするブランチとPull Req. のビルドは異なる
date: 2015-11-25T21:31:46+09:00
tags: 
---

GitHubとTravis CIを連携すると、PRを立てたときデフォルトだとpushとPRそれぞれに対してCIが走る。
2つも要らないんじゃないかと思いつつ放置してたが、push側はパスしたのにPR側がFAILしたということがあった。
同じリビジョンに対してテストしてると思ってたが、どうやら違うみたい。

それぞれのTravis CIのログからソースコードを取得してる部分を見てみると、pushに対しては、

```sh
git clone --depth=50 --branch=my_topic_branch https://github.com/ueokande/my_project.git ueokande/my_project
cd ueokande/my_project
git checkout -qf XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

XXX\.\.\.Xはpushされたリビジョンで、pushされたリビジョンにcheckoutしてビルドを走らせる。
つぎにPRのログを見てみると、

```sh
git clone --depth=50 https://github.com/ueokande/my_project.git ueokande/my_project
cd ueokande/my_project
git fetch origin +refs/pull/XXX/merge:
git checkout -qf FETCH_HEAD
```

おや、push時と違って何やら複雑なことをしている。
どうやらGitHubはPRを作ると `+refs/pull/XXX/merge` といったリファレンスを作る。
このリファレンスが何を指すかを見てみる。

```sh
git fetch origin +refs/pull/XXX/merge
git show FETCH_HEAD
```

このコミットはマージコミットで、マージ先はPRのマージ先。
なるほど、PRのマージ後の状態に対してテストしてるようだ。
なおPRを閉じるとこのリファレンスは消えるみたい。

