---
title: ACアダプタの抜き挿しをデスクトップ通知する
date: 2015-01-12T21:55:17+09:00
tags: [Linux]
---

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2015/01/12/215517/20150112144736.png" alt="f:id:ibenza:20150112144736p:plain" title="f:id:ibenza:20150112144736p:plain" class="hatena-fotolife" itemprop="image"></span>

# 全体の構成

ACアダプタを抜き挿しからデスクトップ通知までの流れは、大体次のようになる。
少し複雑だが、汎用性とカスタマイズ性とお行儀を考えて、journal経由にした。

```
event            logger
```

