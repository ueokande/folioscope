---
title: PDFの日本語が表示されない時のメモ
date: 2012-03-11T19:09:26+09:00
tags: [Linux]
---

システムを入れなおしたらOkularでPDFを見た時日本語が表示されなくなった．

フォントの問題かなと思いAdobe Readerで見ると正常に表示された．

同じくxpdf\-popplerで試してみたところ，Okularと同じ症状となった．

そのためpopplerに原因があるようだ．

  
popplerはPDFビューアのバックエンドで，xpdf\-popplerはもちろんOkularやEvinceで使用されている．

そしてpoppler\-dataパッケージを入れると問題が解決した．

poppler\-dataパッケージは，popplerで使用するフォントに関連するファイルが詰まってるようだ．

