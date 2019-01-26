---
title: Bashのプロンプトを不謹慎にする
date: 2012-11-19T17:59:50+09:00
tags: [GomiScript, sh]
---

Bashのプロンプトは自由に変えることができ，<span style="monospace">PS1</span>という環境変数に設定できます．

例えばDOSのプロンプトが好きな人は次の設定をするといいでしょう．

```sh
export PS1="C:\> "
```

結果はこのようになります（※Unix系OSにはドライブレターはありません）．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/19/175950/20121119175202.png" alt="f:id:ibenza:20121119175202p:plain" title="f:id:ibenza:20121119175202p:plain" class="hatena-fotolife" itemprop="image"></span>

刺激が欲しい人は，次のように設定すると，少し不謹慎ムードに包まれます．

```sh
export  PS1='$(if [[ $? = 0 ]];then echo "\[\033[01;34m\]✈\[\033[00m\]⌂";else echo "\[\033[01;31m\]✹\[\033[00m\]⌂";fi) '
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/19/175950/20121119175204.png" alt="f:id:ibenza:20121119175204p:plain" title="f:id:ibenza:20121119175204p:plain" class="hatena-fotolife" itemprop="image"></span>

また，Macではemojiが使用出来るので，次のように設定するとより華やかになります．

```sh
export  PS1='$(if [[ $? = 0 ]];then echo "??";else echo "??";fi)  '
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/19/175950/20121119175210.png" alt="f:id:ibenza:20121119175210p:plain" title="f:id:ibenza:20121119175210p:plain" class="hatena-fotolife" itemprop="image"></span>

