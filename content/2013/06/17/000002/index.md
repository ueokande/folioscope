---
title: Qt Creator上でのコンパイル時間を短くする
date: 2013-06-17T00:00:02+09:00
tags: [Qt]
---

Qt Creatorは内部で<span style="font-family:monospace">make</span>を呼び出しています．  
<span style="font-family:monospace">make</span>コマンドは<span style="font-family:monospace">-j</span>オプションをつけると，コンパイルを並列に行います．

Qt Creatorで<span style="font-family:monospace">make</span>に渡すオプションは，プロジェクトの設定から行います．  
まずQt Creator右部のメニューから，Projectsを選んでください．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/06/17/000002/20130616221034.png" alt="f:id:ibenza:20130616221034p:plain" title="f:id:ibenza:20130616221034p:plain" class="hatena-fotolife" itemprop="image"></span>  
そしてBuild StepのMakeのMake argumentに<span style="font-family:monospace">-j</span>を追加します．  
すると<span style="font-family:monospace">make</span>に渡されるオプションが増えたことが確認できます．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/06/17/000002/20130616221549.png" alt="f:id:ibenza:20130616221549p:plain" title="f:id:ibenza:20130616221549p:plain" class="hatena-fotolife" itemprop="image"></span>  
あとは通常通り，Buildするだけ．

