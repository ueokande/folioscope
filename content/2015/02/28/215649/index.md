---
title: BashでChefっぽいこと
date: 2015-02-28T21:56:49+09:00
tags: [sh]
---

[{{<img src="http://farm1.staticflickr.com/185/449958332_2a07a72aa3.jpg" alt="">}}](http://www.flickr.com/photos/73491156@N00/449958332)  
[photo by Éole](http://www.flickr.com/photos/73491156@N00/449958332)

# Itamae便利説

Chefっぽいことと言っておきながら、軽量ChefのItamaeしか触ったことありません。
しかし便利ですよね。

[Itamae \- Infra as Code 現状確認会 // Speaker Deck](https://speakerdeck.com/ryotarai/itamae-infra-as-code-xian-zhuang-que-ren-hui)

しかしChefにせよ、itamaeにせよ、環境を入れないと使えません。
とくにローカルの環境を構築したいとき、Rubyの環境やらgemやらを入れる必要があるので、本末転倒感ある。
そこでBashのChefっぽいのを試作してみした。

# Bachef \- ChefっぽいBash

ItamaeやChefのいいところは、RubysでDSLを書くことで、読みやすく管理しやすい点だと思います。
そこでBashをつかってDSLっぽいことにも挑戦してみました。

```sh
#!/bin/bash
 
source 'bachef.sh'
 
remote_file '/etc/nginx/nginx.conf' $(
  source 'templates/nginx.conf'
  mode '755'
)
 
remote_file '/etc/ssh/sshd_config' $(
  source 'templates/nginx.conf'
  mode '700'
  owner 'root'
  group 'root'
)
```

Chefっぽいし、DSLっぽいし、いい感じに。
実行結果はこんな感じ。

```
$ ./test.sh
remote_file[/etc/nginx/nginx.conf]
  - cp templates/nginx.conf /etc/nginx/nginx.conf
  - chmod 755 /etc/nginx/nginx.conf
remote_file[/etc/ssh/sshd_config]
  - cp templates/nginx.conf /etc/ssh/sshd_config
  - chmod 700 /etc/ssh/sshd_config
  - chown root /etc/ssh/sshd_config
  - chgrp root /etc/ssh/sshd_config
```

# Gist貼っておきます

Gist貼っておきます。このコード、まだechoするだけで実ファイルには手を出しません。

[https://gist\.github\.com/ueokande/0b37a673b63781e65ed3](https://gist.github.com/ueokande/0b37a673b63781e65ed3)

