---
title: GNU/Linuxユーザが快適にMacを使うためのTips
date: 2012-09-17T11:09:14+09:00
tags: [Mac]
---

私はGNU系のコマンドが好きだ．一方MacではBSD系のコマンドを使用している．同じコマンド名でも少しオプションが違い，これがものすごく使いにくい．どちらが元祖かなどは関係なく，私はGNU系のコマンドが大好きだ．

さて，ここで取り上げているコマンドとは，<span style="font-family:monospace;">ls</span>や<span style="font-family:monospace;">cat</span>などといった基本コマンドのセットである．これらはGNU系とBSD系では，コマンド名は同じであっても引数や動作が若干異なる．幸いMacPortsにGNU系のコマンドセットがパッケージされているのでインストールしてみよう．

GNU系の基本コマンドは，<span style="font-family:monospace;">coreutils</span>というパッケージに含まれている．またGNU系の<span style="font-family:monospace;">find</span>や<span style="font-family:monospace;">xargs</span>などの検索用のコマンドは<span style="font-family:monospace;">findutils</span>に含まれる．まずこれらをMacPortsでインストールする．

```sh
sudo port install coreutils
sudo port install findutils
```

これらは<span style="font-family:monospace;">/opt/local/bin</span>に<span style="font-family:monospace;">gls</span>や<span style="font-family:monospace;">gfind</span>といった名前でインストールされている．さらに<span style="font-family:monospace;">/opt/local/libexec/gnubin</span>に<span style="font-family:monospace;">ls</span>や<span style="font-family:monospace;">find</span>といった名前でシンボリックリンクが作られる．そのため，<span style="font-family:monospace;">/opt/local/libexec/gnubin</span>にパスを通してしまおう．  
<span style="font-family:monospace;">.bashrc</span>あるいは<span style="font-family:monospace;">.bash_profile</span>に次の一行を追加する．

```sh
export PATH="/opt/local/libexec/gnubin:"$PATH
```

これにより何らかの問題が発生するかもしれないが，まだ問題が起こったことがないのでよしとする．

このままでは<span style="font-family:monospace;">ls</span>の結果に色がついておらず寂しいので，次の行も加える．

```sh
export LS_OPTIONS='-N --color=tty -T 0'
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.xz=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'
alias ls='ls $LS_OPTIONS'
```

また<span style="font-family:monospace;">grep</span>もハイライトができるので，次の行も追加しよう．

```sh
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
```

