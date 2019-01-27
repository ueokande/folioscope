---
title: ターミナルのANSIカラーの分布
date: 2013-12-08T13:41:57+09:00
tags: [Linux]
---

ターミナルとANSIエスケープコードについて調べてみると，どうやら最近の進んだターミナルエミュレータは，256色も出せるらしい．
そこでターミナルの16色モード，256色モードのカラーパレットをまとめた．
なお，16色/256色のモードを，それぞれxterm16/xterm256などとと見聞するが，正式名称は不明．

# xterm16

ターミナルで色を付けるためにANSIで規定されている16色．
ナウくないターミナルでも，とりあえずの16色は出せるはずだ．

おそらく色の決め方は，白と黒，そして色の三原色・光の三原色の計8色を，さらにNormalとLightに分けて，全部で16色．
色の決め方は真っ当であるが，なぜこのような並びになっているかは不明．

<table border="1" width="100%">
  <col> 
  <col style="width:80px"> <col style="width:80px"> <col style="width:80px"> <col style="width:80px"> 
  <col style="width:80px"> <col style="width:80px"> <col style="width:80px"> <col style="width:80px">
  <thead>
    <tr style="font-size:80%;width:180px">
      <th></th>
      <th>Black</th> <th>Red</th> <th>Green</th> <th>Yellow</th> <th>Blue</th> <th>Magenta</th> <th>Cyan</th> <th>White</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th> Normal </th>
      <td style="background-color:#000000;color:white">0</td>
      <td style="background-color:#990000;color:white">1</td>
      <td style="background-color:#00a600;color:white">2</td>
      <td style="background-color:#999900;color:white">3</td>
      <td style="background-color:#0000b2;color:white">4</td>
      <td style="background-color:#b200b2;color:white">5</td>
      <td style="background-color:#00a6b2;color:white">6</td>
      <td style="background-color:#bfbfbf;color:white">7</td>
    </tr>
    <tr>
      <th> Bright </th>
      <td style="background-color:#666666;color:white">8 </td>
      <td style="background-color:#e50000;color:white">9 </td>
      <td style="background-color:#00d900;color:white">10</td>
      <td style="background-color:#e5e500;color:white">11</td>
      <td style="background-color:#0000ff;color:white">12</td>
      <td style="background-color:#e500e5;color:white">13</td>
      <td style="background-color:#00e5e5;color:white">14</td>
      <td style="background-color:#e5e5e5;color:white">15</td>
    </tr>
  </tbody>
</table># xterm256

ちょっと進んだxtermは256色だっておてのもの．
色の割り当ては次のとおりだ．

<table border="1">
  <tr>
    <th>0-15</th> <td>ANSI Colors互換のカラーパレットの領域</td>
  </tr>
  <tr>
    <th>16-231</th> <td>R,G,Bをそれぞれ6段階を表した，6x6x6=216 色の領域
  </td>
</tr>
  <tr>
    <th>232-255</th> <td>グレースケールを24段階で表した，24色の領域</td>
  </tr>
</table># おわりに

xterm16/xterm256のsvgカラーチャートと，カラーテーブルをYAML形式でまとめ親切な人がいました．[https://gist\.github\.com/jasonm23/2868981](https://gist.github.com/jasonm23/2868981)

なお，ANSIのエスケープコードを組み合わせて，ターミナル上にイラストや色彩豊かな文字を表示することを，**ANSI Art**などと言ったりするらしいです．

