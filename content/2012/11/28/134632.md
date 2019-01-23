---
title: \section再定義にハマる
date: 2012-11-28T13:46:32+09:00
tags: [TeX/LaTeX]
---

LaTeXでの<span style="font-family:monospace">\section</span>再定義にハマった．

<span style="font-family:monospace">\section</span>の再定義をしている次のコードをコンパイルすると，下の図のような結果となる．

```tex
\documentclass[]{article}

\makeatletter
\renewcommand\section{\@startsection {section}{1}{\z@}
  {-3.5ex \@plus -1ex \@minus -.2ex}
  {2.3ex \@plus.2ex}
  {\normalfont\Large\bfseries}
}
\makeatother

\begin{document}
\section{AIUEO}
\section*{ABCDE}
\end{document}
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/28/20121125105750.png" alt="f:id:ibenza:20121125105750p:plain" title="f:id:ibenza:20121125105750p:plain" class="hatena-fotolife" itemprop="image"></span>  
これが期待している結果である．  
しかしams系のパッケージを<span style="font-family:monospace">\usepackage</span>すると，たちまち表示が壊れる．

```tex
\usepackage{amsmath}
```

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2012/11/28/20121125105744.png" alt="f:id:ibenza:20121125105744p:plain" title="f:id:ibenza:20121125105744p:plain" class="hatena-fotolife" itemprop="image"></span>

  
どうやら<span style="font-family:monospace">\section</span>の再定義がよろしくなかったみたい．  
正しくは次の通り．

```tex
\renewcommand\section{\@startsection {section}{1}{\z@}%
  {-3.5ex \@plus -1ex \@minus -.2ex}%
  {2.3ex \@plus.2ex}%
  {\normalfont\Large\bfseries}%
}
```

マクロ定義時の<span style="font-family:monospace">%</span>が抜けるという初歩的なミス．

