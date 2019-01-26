---
title: よく使うディレクトリへの移動が捗るコマンドを作りました
date: 2017-03-20T21:00:00+09:00
---

コマンド一発で、普段良く使うディレクトリに移動できる、コマンド「hop」を作りました。

![screenshot.gif](hop.gif)

![github][ueokande/hop]

設定
----

まずは`hop`を適当な場所にgit cloneします。

```sh
git clone https://github.com/ueokande/hop $HOME/.hop
```

そして、`.bash_profile`, `.zprofile`, あるいは `.profile`にて、hopの初期設定を行います。
引数に自分の作業ディレクトリを指定すると、その中のファイルがエントリとして登録されます。

```sh
# Register your workspaces
[ -x $HOME/.hop/hop-update.sh ] && $HOME/.hop/hop-update.sh \
  ~/go/src/github.com/ueokande \
  ~/workspace \
  /usr/src
```

自分で、任意のディレクトリの登録もできます。

```sh
cat >>$HOME/.hoprc <<EOF
Asia=/usr/share/zoneinfo/Asia
Africa=/usr/share/zoneinfo/Africa
EOF
```

そして `.profile` ファイルなどで、初期化用のファイルをロードします。

```sh
[ -r $HOME/.hop/profile ] && source $HOME/.hop/profile
```

Bashユーザには便利なbash-completionも用意してあります。

```sh
[ -r $HOME/.hop/bash-completion ] && source $HOME/.hop/bash-completion
```

