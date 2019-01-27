---
title: TeXで宛名印刷
date: 2014-01-13T22:14:55+09:00
tags: [TeX/LaTeX]
---

毎年の年賀状での一番の大仕事は、宛名の作成である。LibreOfficeの差し込み印刷を使用していたが、その操作は複雑で、毎年年末に同じことに頭を悩ます。
そこで来年に備えて、TeXで宛名印刷を行うことにした。

TeXでの作成は、プレーンテキストベースのファイルなので、バージョン管理がしやすい。
また途中で行われる処理も透明化するので、保守性も高い。TeXで宛名印刷してる人はWeb上で何人か見かけたが、
自分の満足の行くものではなかったので自分でクラスファイルを作ることにした。

{{<github src="ueokande/jletteraddress">}}

# 使い方

使い方はいたって簡単。
ドキュメントクラスを指定して、差出人の住所と、受取人の住所を必要なだけ書くだけです。

```tex
\documentclass[]{jletteraddress}

%% 差出人
\sendername{差出　花子} 
\senderaddressa{送主県送主市送主町一二三} 
\senderaddressb{送主グランド四五六} 
\senderpostcode{1234567}

\begin{document}
\addaddress
  {受取 太郎}{様}        % 名前
  {9876543}             % 郵便番号
  {宛名県宛名市九ー八ー七} % 住所1 
  {コーポ宛名六五四}      % 住所2 
\end{document}
```

コンパイルも通常のTeXドキュメントと同じ。

```
$ platex example && dvipdfmx example
```

pLaTeX/dvipdfmxを使っている人は、PDFのしおり機能で、宛名を一覧表示することができます。

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2014/01/13/221455/20140113113848.png" alt="f:id:ibenza:20140113113848p:plain" title="f:id:ibenza:20140113113848p:plain" class="hatena-fotolife" itemprop="image"></span>

