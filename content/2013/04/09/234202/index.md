---
title: ホスト毎にプロンプトを変える
date: 2013-04-09T23:42:02+09:00
tags: [sh]
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/04/09/234202/20130409183925.png" alt="f:id:ibenza:20130409183925p:plain" title="f:id:ibenza:20130409183925p:plain" class="hatena-fotolife" itemprop="image"></span>  
複数のマシンにログインすると，今どのマシンに居るかが把握しにくい．  
そこでプロンプトの色を，ホスト毎に変えてみる．  
<span style="font-family:monospace;">.bashrs</span>や<span style="font-family:monospace;">.bash_profile</span>に次を追加．

```sh
host=`hostname -s`
case $host in
  "host1")    color="31";;
  "host2")   color="32";;
esac
export PS1="\[\033[1m\]\u@\[\033[${color};1m\]\h\[\033[m\]\[\033[1m\]:\W> \[\033[m\]"
```

case文でホスト毎に色を設定して，環境変数<span style="font-family:monospace;">PS1</span>をセットするだけ．

