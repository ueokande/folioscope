---
title: openSUSEでスクリーンキャスト
date: 2011-01-06T00:45:59+09:00
tags: [Linux, openSUSE]
---

LinuxでUstreamなどへデスクトップをストリーミングする方法です\.  
openSUSE 11\.3を使用しました  
Linux用のスクリーンキャストのソフトは少なく, どれももっさりしたりと満足できるものが無かったので, 少々手間ですが, <span style="font-weight:bold;">vloopback</span>と呼ばれるモジュールを使ってストリーミングしたいと思います  
vloopbackは, データを入力して,仮想的なビデオデバイスとして出力してくれます  
なお配信までの手続きは, 次のサイトを参考にしました  
Linuxでデスクトップをライブ配信する \- hyconの日記  
[http://d\.hatena\.ne\.jp/hycon/20100923/1285226128](http://d.hatena.ne.jp/hycon/20100923/1285226128)  
より詳しく書いてあるので平行して読んでくだしあ

READMORE
#### 必要な物

- vloopback
- mjpegtools\_yuv\_to\_v4l
- ffmpeg

#### 1\. カーネルモージュールのインストール

まずvloopbackのコンパイルに必要なモジュールをインストールします  
YaST2のソフトウェア管理から, <span style="font-style:italic;">kernel-desktop-devel</span>の自分のカーネルにあったバージョンをインストールします  
カーネルのバージョンは次のコマンドで調べることができます

```
uname -r
```

#### 2\. vloopbackのインストール

ソースをsvnからダウンロードします

```
svn co http://www.lavrsen.dk/svn/vloopback/trunk/ vloopback
```

ダウンロードしたらvloopback/ディレクトリに移動してmakeしてインストールします  
なお/lib/modules/2\.6\.\*\*\*\*\*\*が見つからないといわれてコンパイルできない時は, カーネルモジュールのバージョンが間違っている可能性があります

#### 3\. mjpegtools\_yuv\_to\_v4lのインストール

mjpegtools\_yuv\_to\_v4lは入力した映像をvloopback用に変換してくれます  
[http://panteltje\.com/panteltje/mcamip/mjpegtools\_yuv\_to\_v4l\-0\.2\.tgz](http://panteltje.com/panteltje/mcamip/mjpegtools_yuv_to_v4l-0.2.tgz)  
から, ソースをコンパイルしてインストールします

#### 4\. ffmpegのインストール

インストールが楽なので, YaST2のソフトウェア管理からffmpegをインストールしたいと思います  
まずopenSUSEの初期のリポジトリにはffmpegが無いので, Packmanリポジトリを追加します  
次のリンクから, 自分のバージョンにあったPackmanリポジトリを選びます  
[http://en\.opensuse\.org/Additional\_package\_repositories\#Packman](http://en.opensuse.org/Additional_package_repositories#Packman)  
そしてYaST2のソフトウェアリポジトリから, \[追加\]→\[URLの指定\]で, リポジトリを追加します  
そうするとYaST2のソフトウェア管理にffmpegがあるはずなので, インストールします

#### 5\. いよいよ配信

まず,

```
sudo /sbin/modprobe vloopback pipes=1
```

を実行して, vloopbackモジュールを作成します\(pipesを指定しなくても動くかも\)  
dmesgで

```
[ 4505.599710] [vloopback_init] : video4linux loopback driver v1.4-trunk
[ 4505.600483] [vloopback_init] : Loopback 0 registered, input: video0, output: video1
[ 4505.600485] [vloopback_init] : Loopback 0 , Using 2 buffers
```

などと表示されていれば成功です  
そして,

```
ffmpeg -f x11grab -s 320x240 -r 10 -i :0.0+0,0 -pix_fmt yuv420p -f yuv4mpegpipe - \
    | mjpegtools_yuv_to_v4l /dev/video0
```

と実行すると, キャプチャが始まります\(320x240じゃないとUstreamで乱れるのでとりあえずの簡易設定\)  
後は適当なビューアで見てみましょう

[![f:id:ibenza:20110107002458p:image](/2011/01/06/1294328759/20110107002458.png)](http://f.hatena.ne.jp/ibenza/20110107002458)

