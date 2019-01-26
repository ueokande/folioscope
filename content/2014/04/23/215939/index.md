---
title: Mutt on Homebrewでサイドバーパッチ
date: 2014-04-23T21:59:39+09:00
tags: [Mac]
---

openSuSEのmuttのパッケージには、サイドバーのパッチがあたっているが、OS Xのhomebrewに含まれるパッケージには含まれていない。
そこでhomebrewでMuttにサイドバーのパッチをあて、インストールするまでを記す。

まず、muttのFormulaを編集。

```
$ homebrew edit mutt
```

35行目付近に、コンパイルオプションを追加する。

```
option "with-sidebar-patch", "Apply sidebar patch"
```

そして50行目付近にパッチのurlが書かれている場所があるので、その付近に次の3行を追加。

```
patch do
  url "https://raw.github.com/nedos/mutt-sidebar-patch/master/mutt-sidebar.patch"
end if build.with? "sidebar-patch"
```

sha1は指定しなくてもWarningされるだけです。

あとは`--with-sidebar-patch`オプションを付けてインストール。

```
$ brew install mutt --with-sidebar-patch
```

# 参考

- [http://comments\.gmane\.org/gmane\.mail\.mutt\.user/41752](http://comments.gmane.org/gmane.mail.mutt.user/41752)

