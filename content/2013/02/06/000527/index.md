---
title: nginx + webalizer でアクセス解析
date: 2013-02-06T00:05:27+09:00
tags: [Linux]
---

nginxとwebalizerを使ってアクセス解析するためのナイスな設定例が少ないのでメモ．

### アクセス解析の準備

webalizerは本来Apacheのログを読みに行くので，nginxの出力するログをApacheに合わせます．  
<span style="font-family:monospace;">/etc/nginx/nginx.conf</span>ファイルのhttpセクションにある<span style="font-family:monospace">log_format</span>を以下のように設定します．

```
http {
  .....
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '"$status" $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" "$gzip_ratio"';
  .....
}
```

そしてwebalizerが読みに行くログの場所を，nginxのログの場所に設定します．  
<span style="font-family:monospace">/etc/webalizer.conf</span>を次のように設定します．

```
LogFile         /var/log/nginx/access.log
```

また<span style="font-family:monospace">webalier</span>の出力先も変えておきましょう．  
このディレクトリは予め作成しておきます．

```
OutputDir      /var/www/webalizer
```

#### 解析を行う

webalizerはデーモンではなく，処理がすぐに帰ってくる系プロセスです．  
解析をおこなうには，管理下権限で<span style="font-family:monospace">webalizer</span>を実行します．

```
> webalizer
```

処理が成功すると<span style="font-family:monospace">/var/www/webalizer</span>に解析結果が出力されているはずです．  
エラーがなかったら<span style="font-family:monospace">/etc/crontab</span>に登録します．

```
0 0 * * * * root /usr/bin/webalizer
```

### 解析結果を見る

解析結果は外部に公開したくは無いが，httpsなどで認証・暗号化するのは少々手間です．  
そこで少し手を抜いて，localhostにのみ公開します．  
nginxの設定で次のように新たにserverを作成し，ファイアウォールで閉じられている適当なポートにのみ公開します．

```
server {
  listen       8080 default_server;
  server_name  <server_name>
  location / {
    root   /var/www/webalizer;
    index  index.html index.htm;
    access_log off;
  }
}
```

webalizerのページにアクセスするには，サーバにログインし[http://localhost:8080/](http://localhost:8080/)を開きます．  
この図は，w3mで開いた時のスクリーンショットで，これでも十分に使えます．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/02/06/000527/20130204131137.png" alt="f:id:ibenza:20130204131137p:plain" title="f:id:ibenza:20130204131137p:plain" class="hatena-fotolife" itemprop="image"></span>  
またsshでLocal Forwardを使って，ローカルホスト側で見る方法もあります．  
次のようにsshのセッションを開始して，ローカルホストのブラウザでlocalhost:12321を開きます．

```
ssh -L12321:localhost:8080 -p11235 <server_name>
```

### P\.S\.

ssh越しでw3mを起動しても，マウスクリックでリンクを踏むことができるのを知りました．

