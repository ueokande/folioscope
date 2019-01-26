---
title: VimConf2016に行ってきた
date: 2016-11-06T08:02:00+09:00
tags: [Vim]
---

[VimConf 2016](http://vimconf.vim-jp.org/2016/)に参加してきました
全タイトルを雑に振り返ってみます。
自分はVim力が足りないので、参加報告も足りない語彙力でお送りします。

当日参加できなかったという方も、当日のストリームが残っているのでどうぞ  
[VimConf 2016 - YouTube](https://www.youtube.com/watch?v=5CnewLJi0b0)


## Introduction to Vim 8.0

<iframe src="//www.slideshare.net/slideshow/embed_code/key/8Y5M3Gz8b68Q18" width="480" height="320" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>
[Introduction to Vim 8.0](http://www.slideshare.net/k-takata/introduction-to-vim-80)
from [Ken Takata](https://github.com/k-takata)

Vim 8.0がリリースされてから2ヶ月が経とうというのに、自分は全然追えていなかったので非常に助かりました。
Vimの歴史も見れて面白かったです。
途中でコントリビューターの数が出てたのですが、ユーザ数を考えるとむしろ少ないのでは？と思いました。

## Vim as the MAIN text editor

<div style='width:480px; height:320px; margin: 16px 0 128px'>
<script async class="speakerdeck-embed" data-id="49561b16888d47ad9236120958b8d786" data-ratio="1.37081659973226" src="//speakerdeck.com/assets/embed.js"></script>
</div>
[Vim as the MAIN text editor](https://speakerdeck.com/bird_nitryn/vim-as-the-main-text-editor-number-vimconf2016)
from [bird_nitryn](https://github.com/rnitame)

Vimを生活の中心に取り入れようというお話。VSCodeからVimに転向したそうです。
自分は意識的にVimの機能を使おうと思ったことが無いので、網羅できていない機能もあるんじゃないのかと思いました。
dotfilesをissue駆動で管理しているというのは面白かったです。

## Denite.nvim ~The next generation of unite~

[Denite.nvim ~The next generation of unite~](https://gist.github.com/Shougo/7c78b3a1725f70c1435d004ed14f2558)
from [Shougo](https://github.com/Shougo)

Dark poweredなプラグインは早いです。Python3で書くことで早くなります。NeoVimだけでなくVim 8.0でも動くのでみんなが嬉しい。

## Go、C、Pythonのためのdeoplete.nvimのソースの紹介と、Neovim専用にpure Goでvim-goをスクラッチした話

[<img style="width:480px" title="deoplete sources and nvim-go" src="/2016/11/06/vimconf-2016-report/vimconf-2016-report/deoplete-sources-and-nvim-go.png" />](http://go-talks.appspot.com/github.com/zchee/talks/vimconf2016.slide)  
[Go、C、Pythonのためのdeoplete.nvimのソースの紹介と、Neovim専用にpure Goでvim-goをスクラッチした話](http://go-talks.appspot.com/github.com/zchee/talks/vimconf2016.slide)
from [zchee](https://github.com/zchee)

前半はShougoさんのdeopleteのお話、後半はnvim-goフルスクラッチのお話。
deopleteの各言語のバインディングはシュッと書けるらしい。
nvim-goはGoが捗りそうでした。

## エディタの壁を越えるGoの開発ツールの文化と作成法

<iframe src="//www.slideshare.net/slideshow/embed_code/key/FJofSN8tVozg1j" width="480" height="320" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>
[エディタの壁を越えるGoの開発ツールの文化と作成法](http://www.slideshare.net/takuyaueda967/go-68228940)
from [tenntenn](https://github.com/tenntenn)

Goの宣伝っぽかったけど、改めてGoの良さがわかった。
またGoの規約の方針についても、良さを感じました。  
＿人人人人人人人＿  
＞　ʕ⦿ϖ⦿ʔ　＜  
￣Y^Y^Y^Y^Y^Y￣

## vim-mode-plus for Atom editor

[<img style="width:480px" title="vim-mode-plus for Atom editor" src="/2016/11/06/vimconf-2016-report/vimconf-2016-report/vim-mode-plus-for-atom-editor.png" />](http://qiita.com/t9md/items/0bc7eaff726d099943eb)  
[vim-mode-plus for Atom editor](http://qiita.com/t9md/items/0bc7eaff726d099943eb)
from [https://github.com/t9md](t9md)

Atomのvim-mode-plusプラグインのお話だけど、発表者さんはVim -> Emacs -> Vim -> Atomという遍歴を持ってるお方。
Atomエディタならではの、きれいなハイライトやstay-on機能などは良さを感じました。Vimに逆輸入されるのを待つのみです。
またVimのコマンドを形式言語的に解説されていたのが面白かったです。

## Vimの日本語ドキュメント

from <a href="https://github.com/koron" target="_blank">MURAOKA Taro</a>

Vim日本語ドキュメントコントリビューター大変！というお話。
Vim日本語プロジェクトも、ユーザー数とコントリビューターのバランスが会ってないように感じました。
オープンなプロジェクトに貢献する文化、プログラマ以外にももっと広がってほしいです。

## Vim script parser written in Go

[<img style="width:480px" title="Vim script parser written in Go" src="/2016/11/06/vimconf-2016-report/vimconf-2016-report/vim-script-parser-written-in-go.png" />](https://docs.google.com/presentation/d/1A6_A7XzPoHv_wG5N_R6zbgYKBX2ycii6BCzR-7b-nOw/pub?start=false&loop=false&slide=id.p)  
[Vim script parser written in Go](https://docs.google.com/presentation/d/1A6_A7XzPoHv_wG5N_R6zbgYKBX2ycii6BCzR-7b-nOw/pub?start=false&loop=false&slide=id.p)
from [haya14busa](https://github.com/haya14busa)

本日３度めのGo関連のお話。
Goはいいぞ。

## 僕の友達を紹介するよ

<iframe src="//aiya000.github.io/Maid/my-vim-friends/my-vim-friends#/" width="480" height="320" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>
[僕の友達を紹介するよ](https://aiya000.github.io/Maid/my-vim-friends/my-vim-friends#/)
from [aiya000](https://github.com/aiya000)

> いつVimを使い始めたのか覚えてない｡学生時代、知らないうちにVimを使い始めていた。

同意

## Best practices for building Vim plugins

[Best practices for building Vim plugins](https://gist.github.com/thinca/785171e327e66c48d2d293690dc2f65a)
from [thinca](https://github.com/thinca)

Vimプラギンを作る上でのお約束。
名前が衝突しない仕組みがVimに無く、好き勝手に名前を使っているプラグイン作者もいる。
自分も作るときは気をつけようと思った
Helpは仕様書。

* * *

## 最後に

100行ちょっとの.vimrcとわずかなプラグインで満足していましたが、自分のVimはまだまだ磨きが足りないと言うことを実感しました。
自分が不便なVimを使っているということすら、自分で気付けていなかったようです。
考えてみると補完やリファクタ、デバッグなどの機能を高望みしていなかった節があります。
まずは自分の大好きなシェルスクリプトから、良さげなプラギンを探す or 作るところから始めたいと思います。

