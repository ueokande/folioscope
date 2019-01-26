---
title: boostのグラフ別，動作の違い
date: 2012-10-31T22:42:38+09:00
tags: [C/C++, boost]
---

boostにあるグラフライブラリのグラフの種類と動作の違いをまとめてみた．  
boostのグラフには辺の向きのタイプが3種類用意されている．

<dl>
<dt>directedS</dt>
<dd>有向グラフ．</dd>
<dt>undirectedS</dt>
<dd>無効グラフ．</dd>
<dt>bidirectionalS</dt>
<dd>有向グラフだが，双方向に走査できる．</dd>
</dl>


またboostには，ある頂点に隣接する辺や頂点を取得する関数がいくつかある．

<dl>
<dt>adjacent_vertex()</dt>
<dd>ある頂点に隣接する全ての頂点を取得する</dd>
<dt>in_edge()</dt>
<dd>ある頂点の全ての入辺を取得する</dd>
<dt>out_edge()</dt>
<dd>ある頂点の全ての出辺を取得する</dd>
</dl>


これらのグラフの種類と各メソッドの動作の違いを調べてみる．

まず次のようにグラフを作成

```cpp
graph_type g;
typename graph_type::vertex_descriptor v1, v2, v3;
v1 = boost::add_vertex(g);
v2 = boost::add_vertex(g);
v3 = boost::add_vertex(g);
boost::add_edge(v1, v2, g);
boost::add_edge(v2, v3, g);
```

有向グラフで表すと次のようなグラフである．  
![f:id:ibenza:20121031094333p:plain](/2012/10/31/224238/20121031094333.png)  
ここで各関数にv2を放り込んで，帰ってきた結果が次の表のようになった．

<table>
    <tr>
    <th>                 </th>
    <th>directedS</th>
    <th>undirectedS</th>
    <th>bidirectionalS</th>
    </tr>
    <tr>
    <td>adjacent_vertex() </td>
    <td>v3</td>
    <td>v1, v3</td>
    <td>v3</td>
    </tr>
    <tr>
    <td>in_edge()         </td>
    <td>-</td>
    <td>(v1,v2), (v2,v3)</td>
    <td>(v1,v2)</td>
    </tr>
    <tr>
    <td>out_edge()        </td>
    <td>(v2,v3)</td>
    <td>(v1,v2), (v2,v3)</td>
    <td>(v2,v3)</td>
    </tr>
</table>
ここでdirectedSのin\_edge\(\)のデータが無いのはコンパイルができなかったからである．  
うーむ，boostよくできている．

