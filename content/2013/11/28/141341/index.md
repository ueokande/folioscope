---
title: ターミナルにドットを描画
date: 2013-11-28T14:13:41+09:00
tags: [sh, GomiScript]
---

LinuxなどのコンソールはANSIが制定した画面制御機能を使用することで，カーソルの移動や文字色・背景色を設定できる．
例えば`"\033[${y};${x}f"`をコンソールに出力することで\(`${x}`,`${y}`\)にカーソルを移動する．
また`"\033[$attr;${bg};${fg}m"`を出力することで背景色，文字色をそれぞれ`${bg}`,`${fg}`に設定できる．

これらを組み合わせることで，ターミナルの任意の場所にドットを打つ関数を次のように実装できる．

```sh
## Put a pixel at (x,y).  Position x and y are given by argument $1
## and $2.  The color of the pixel is given by $3, which runs 0 - 7
function putPixel {
  if [ $# -lt 3 ]; then
    echo too few arguments >&2
    return 1
  fi
  x=`echo "$1 * 2" | bc`
  y=$2
  fg=3$3
  bg=4$3
  printf "\033[${y};${x}f"
  printf "\033[$attr;${bg};${fg}m  \033[m"
}
```

# 応用例

この関数を使って，ターミナルにサイン波を描くプログラムを作った．

[A script which draws sin graph in terminal · GitHub](https://gist.github.com/ueokande/7687234)

実行結果はこちら．

<span itemscope itemtype="http://schema.org/Photograph"><img src="/2013/11/28/141341/20131128133230.png" alt="f:id:ibenza:20131128133230p:plain" title="f:id:ibenza:20131128133230p:plain" class="hatena-fotolife" itemprop="image"></span>

