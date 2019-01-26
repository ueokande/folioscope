---
title: いろんなサイトのスパム対策
date: 2013-01-12T00:04:24+09:00
tags: [コラム・雑談]
---

メールアドレスをそのままWebページに掲載すると，クローラによってメールアドレスが採集され，スパムメールの被害に合う可能性が高くなります．全うなWebサービスの場合，メールアドレスを公開するときにはスパム対策を施しているはずです．そのうちいくつかの方法を紹介します．

#### vim online

vim onlineは古典的な方法で，メールアドレスの<span style="font-family:monospace">@</span>と<span style="font-family:monospace">.</span>を画像として表示しています．

```html
username<img src="/images/emailat.png" width="7" height="11">example<img src="/images/emaildot.png" width="4" height="11">com
```

#### GitHub

GitHubの場合メールリンクの<span style="font-family:monospace">data-email</span>属性にパーセントエンコーディングされたメールアドレスが入っています．そしてJavascriptにより<span style="font-family:monospace">{email}</span>という文字列をメールアドレスに置換します．

```html
<a class="email js-obfuscate-email" data-email="%75%73%65%72%6e%61%6d%65%40%65%78%61%6d%70%6c%65%2e%63%6f%6d" href="mailto:{email}">{email}</a>
```

#### Iddy

Iddyは非常に単純です．メールアドレス中の<span style="font-family:monospace">@</span>や<span style="font-family:monospace">.</span>をHTMLの文字参照で記述しています．

```html
username&#64;example&#46;com
```

#### Hatena

HatenaはJavascriptにより<span style="font-family:monospace">mailto:</span>の文字を分離し，<span style="font-family:monospace">\uXXXX</span>のようにUnicodeで参照をしています．

```html
<script type="text/javascript"><!--document.write('<a href="mai' + 'lto:\u0075\u0073\u0065\u0072\u006E\u0061\u006D\u0065\u0040\u0065\u0078\u0061\u006D\u0070\u006C\u0065\u002E\u0063\u006F\u006D">\u0075\u0073\u0065\u0072\u006E\u0061\u006D\u0065\u0040\u0065\u0078\u0061\u006D\u0070\u006C\u0065\u002E\u0063\u006F\u006D</a>');--></script>
```

#### i\-beam\.org

最後に私のサイトになりますが，空の<span style="font-family:monospace">href</span>属性の<span style="font-family:monospace">&lt;a&gt;</span>タグを用意し，Javascriptの<span style="font-family:monospace">String.fromCharCode()</span>メソッドを使って動的に<span style="font-family:monospace">href</span>属性を書き換えています．

```html
<body onload="document.getElementById('contact').href=String.fromCharCode(109,97,105,108,116,111,58,113,101,101,120,101,101,64,97,112,97,110,117,109,46,111,114,103)">
<a href="" id="contact">Contact</a>
```

- - - \-





同じスパム対策でも，サイトごとに特色が異なります．  
このような視点でWebサイトを巡回すると，色々と面白いものが見えてきます．

