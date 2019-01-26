---
title: Macのtexmf
date: 2013-01-24T23:26:59+09:00
tags: [TeX/LaTeX, Mac]
---

Macでユーザ用の<span style="font-family:monospace">texmf</span>の配置場所に困った．  
<span style="font-family:monospace">mktexlsr</span>を実行してもユーザ用の<span style="font-family:monospace">ls-R</span>が作られてなさげ．  
<span style="font-family:monospace">mktexlsr</span>は<span style="font-family:monospace">$TEXMFDBS</span>を走査するが，Mac用のTex Liveだとどうやらユーザ用に設定されていないように見える．  
<span style="font-family:monospace">$TEXMFDBS</span>は次のファイルで設定される．

- <span style="font-family:monospace">/usr/local/texlive/2011/texmf/web2c/texmf.cnf</span>

ここではLinux用に配布されているtexliveの設定を参考にする．

```
% TEXMFDBS = {!!$TEXMFSYSCONFIG,!!$TEXMFSYSVAR,!!$TEXMFMAIN,!!$TEXMFLOCAL,!!$TEXMFDIST}
TEXMFDBS = $TEXMF;$VARTEXFONTS
```

そして<span style="font-family:monospace">mktexlsr</span>を再び実行して次のメッセージが表示されればOK．

```
mktexlsr: Updating /Users/<USER>/Library/texmf/ls-R...
```

  
<span style="font-family:monospace"></span>

