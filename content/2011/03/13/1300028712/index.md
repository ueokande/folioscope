---
title: オサャレなWebページ切り替え その2
date: 2011-03-13T00:05:12+09:00
tags: [jQuery]
---

あいかわらずjQueryが楽しくて  
[前回の記事](http://d.hatena.ne.jp/ibenza/20110222)でフェード効果でページ内への読み込みをしました  
今回はそれをちょっと改良

READMORE
変更点は, aタグでリンクできるところと, その他もろもろです

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html lang="ja">
  <head>
    <title>Load page sample</title>
    <style type="text/css">
      <!--
      .loading{
        background-image:url('loading.gif');
        background-repeat:no-repeat;
        background-position: center;
      }
      -->
    </style>
    <script src="http://code.jquery.com/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script type="text/javascript">
      <!--
      $(function() {
        $('a.inline').click( function(){
          var navi = $(this).attr("href");
          $('#container').fadeOut("fast", function() {
            $(this).empty().addClass('loading').show();
            $(this).load(navi, function() {
              $(this).removeClass('loading');
              $(this).hide();
              $(this).fadeIn("fast");
            });
          });
          return false;
        });
      });
      // -->
    </script>
  </head>
  <body>
    <a href="a.html" class="inline">aaa</a>
    <a href="b.html" class="inline">bbb</a>
    <div id="container" style="height:800px"></div>
  </body>
</html>
```

htmlのソースでは普通にaタグでリンク先を指定しているだけです  
しかしaタグのclickイベントを拾い, href属性を取得して, jQuery側でloadします  
そしてclickイベントのコールバック内で<span style="font-style:italic;">false</span>を返すことで, clickのイベントを親元に送りません  
こうすることで, ブラウザ側でのロードを禁止できます  
[Thickbox](http://jquery.com/demo/thickbox/)などが似たようなことをしているのでしょうかね  
ソース見たことないけども

