---
title: Gmailの言語設定とメールボックス
date: 2013-09-02T21:53:23+09:00
tags: 
---

MuttからGmailのメールボックスにアクセスできなくなった．  
INBOXは見れるが，他のDraftsやAll MailにアクセスするとUnknown Mailboxがかえってくる．  
これはおかしいと思い，Muttでメールボックスの一覧を取得すると，言語設定が悪いということがわかった．

GmailのDraftsやAll Mailのメールボックス名は，Gmail言語設定によって勝手に変わるらしい．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/09/02/20130902174448.png" alt="f:id:ibenza:20130902174448p:plain" title="f:id:ibenza:20130902174448p:plain" class="hatena-fotolife" itemprop="image"></span>

##### Englishの場合

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/09/02/20130902174500.png" alt="f:id:ibenza:20130902174500p:plain" title="f:id:ibenza:20130902174500p:plain" class="hatena-fotolife" itemprop="image"></span>

##### 日本語の場合

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/09/02/20130902174509.png" alt="f:id:ibenza:20130902174509p:plain" title="f:id:ibenza:20130902174509p:plain" class="hatena-fotolife" itemprop="image"></span>

##### Deutschの場合

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/09/02/20130902174519.png" alt="f:id:ibenza:20130902174519p:plain" title="f:id:ibenza:20130902174519p:plain" class="hatena-fotolife" itemprop="image"></span>

一方INBOXのみが取得できた理由は，INBOXという名前がIMAPの仕様で決められている．  
[RFC 3501 \- INTERNET MESSAGE ACCESS PROTOCOL \- VERSION 4rev1](http://tools.ietf.org/html/rfc3501)  
他のメールボックスについては自由である．

  
メールボックスのローカライズが必要なユーザは，メールボックスを意識してアクセスしないだろうし，メールボックスへ意識してアクセスするユーザは，ローカライズは迷惑だろうと思う．  
Googleの実装が謎である．

