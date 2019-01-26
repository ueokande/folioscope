---
title: LaTeXで太字をキレイにする
date: 2012-11-14T10:36:02+09:00
tags: [TeX/LaTeX]
---

LaTeXの<span style="font-family:monospace;">\textbf</span>コマンドは文字を太字\(boldface\)にするコマンドであるが，日本語の場合ゴシック体で表示される事が多い．そのためpLaTeXで作成した文章で，太字あるいはセクションにゴシック体とセリフ体が混ざってキモい（気持ち悪い）．  
<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/14/103602/20121114100450.png" alt="f:id:ibenza:20121114100450p:plain" title="f:id:ibenza:20121114100450p:plain" class="hatena-fotolife" itemprop="image"></span>

そこでTeXのソースに次のプリアンブルを追加する．

```tex
%%%% Sectionのフォント設定
\usepackage{sectsty}
\allsectionsfont{\bfseries\sffamily}

%%%% ¥textbfのフォント設定
\renewcommand{\textbf}[1]{{\bfseries\sffamily#1}}

%%%% タイトルのフォント設定
\makeatletter
\renewcommand{\title}[1]{\gdef\@title{\bfseries\sffamily#1}}
\makeatother
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/14/103602/20121114100447.png" alt="f:id:ibenza:20121114100447p:plain" title="f:id:ibenza:20121114100447p:plain" class="hatena-fotolife" itemprop="image"></span>

あゝキモイ（気持ちいい）．

