---
title: XScreenSaverのSonarが実行できない時
date: 2013-05-02T23:11:53+09:00
tags: [Linux]
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/05/02/20130502231044.png" alt="f:id:ibenza:20130502231044p:plain" title="f:id:ibenza:20130502231044p:plain" class="hatena-fotolife" itemprop="image"></span>  
XScreenSaverのSonar実行時に，本来実在するホストが表示されて欲しいところが，

> Sonar must be etuid to ping\!  
> Running simulation instead\.
> 

と表示されるとき．

この問題に対する解決法については，manを参照できる．

```
man sonar
```

マニュアル曰く，このプログラムはICMP RAWソケットを作成するため，大抵のUnixシステムでは，pingにrootとしてsetuidする必要があるとのこと．  
だから次のコマンドを実行してくれと．

```
chown root:root sonar
chmod u+s sonar
```

sonarは<span style="font-family:monospace">/usr/lib/xscreensaver/sonar</span>あるいは<span style="font-family:monospace">/usr/lib64/xscreensaver/sonar</span>にある場合が多い．

