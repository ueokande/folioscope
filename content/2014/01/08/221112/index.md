---
title: GitのRemote URLを極限まで短く
date: 2014-01-08T22:11:12+09:00
tags: 
---

現在自分は，VPSにプライベートGitリポジトリをおいており，SSHでアクセスしている．リポジトリをたくさん持つと，リモートホストの指定をより短くしたいと思うのが人間の性である．
GitでSSHプロトコルを使用するにはURLに`ssh://...`を使用すればいいのだが，
scp\-likeでも指定できる．

```
$ git clone [user@]host.xz:path/to/repo.git/
```

これをどうして短くしようか．

GitでSSHプロトコルを使用するとき，システム内部の`ssh`コマンドを使用する．
つまりSSHの設定ファイルをロードする．`.ssh/config`に次のように設定を記述してみる．

```
HOST mygit
HOSTNAME myhost.example.com
USER git 
PORT 12345
```

するとどうだろう，SSHで`mygit`にアクセスでき，Gitからも`mygit`にアクセスできる．

```
$ git clone mygit:path/to/repo.git/
```

そしてscp\-likeということは`path/to/repo.git`とすると，リモートホストのホームディレクトリからの相対パスとなる．
そのためリモートホストのホームディレクトリにリポジトリを使用すると，パスを省略できる．

```
$ git clone mygit:repo.git
```

そして実は，末尾の`.git`というのは省略可能である．
よって最終的には次のようになる．

```
$ git clone mygit:repo
```

どうだろうか，ずいぶんと短くなった．

SSHでアクセスできるGitHubも同じく，`.ssh/config`で短くしよう．

```
HOST github
HOSTNAME  github.com
USER git
```

```
$ git clone github:username/repo_name
```

