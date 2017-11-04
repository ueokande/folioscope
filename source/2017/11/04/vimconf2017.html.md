---
title: VimConf2017に行ってきた
date: 2017-11-04 22:00 JST
---

VimConf2017に行ってきました。
日頃の感謝の意を込めて、**個人スポンサー**として参加しました。

![VimConf2017](vimconf2017.jpg)

## Vim, Me and Community

[@haya14busa](https://twitter.com/haya14busa)さんによる、Vimを使い始めたきっかけと、Vim/Vim pluginへの貢献についてのお話です。

[https://docs.google.com/presentation/d/14pViuMI_X_PiNwQD8nuGRG72GUqSeKDqoJqjAZWS39U](https://docs.google.com/presentation/d/14pViuMI_X_PiNwQD8nuGRG72GUqSeKDqoJqjAZWS39U)

自分もVim歴は5年くらいになるのですが、自分はそこまでは至ることができませんでした。
この発表で@haya14busaさん自身も言ってましたが、パッチの裏には何人もの人たちが関わっていました。
こういった議論がオープンな場で交わせるようになった現代は、いい時代になったと思いました。


## The Past and Future of Vim-go

[@fatih](https://twitter.com/fatih)さんによる、vim-goのお話です。

[https://speakerdeck.com/farslan/the-past-and-future-of-vim-go](https://speakerdeck.com/farslan/the-past-and-future-of-vim-go)

同時通訳があったのですが、@fatihさんの英語も聞き取りやすかったのでそのまま聞いてました(通訳も味があって盛り上がってましたが)。
vim-goのプラグインの導入は、vim-goただ1つでよかったり、`:GoInstallBinaries`で必要な依存がインストールされたりと、導入がとても楽です。
その思想がvim-goが広く使われる理由だと思いますし、自分もそうじゃなかったら使ってなかったのかも知れません。
今後のvim-goの進化にも期待です。

## Talk show

[@mattn_jp](https://twitter.com/mattn_jp)さん、[@k_takata](https://twitter.com/k_takata)さん、[@kaoriya](https://twitter.com/kaoriya)さんによるトークショーです。

自分は古い時代のVimやインターネットをあまり知らないので、昔の話を聞くだけでもすごく楽しいですしためになります。
そしてGitHubで議論したりパッチを投げられる今の時代に感謝です。
あと、Vimの開発体制も知れてよかったです。

## Creating your lovely color scheme

[@cocopon](https://twitter.com/cocopon)さんによる、lovelyなvim colorschemeを作るお話です。

https://speakerdeck.com/cocopon/creating-your-lovely-color-scheme

「コンセプトを決める」「基本カラーを元に色を増やす」などデザインとして大事な話から、どうVim colorschemeを書くかというお話でした。
そしてきれいなcolorschemeを作るだけでなく、アクセシビリティや256color対応のお話もされてました（自分も`$TERM`は`xterm-256color`です）。
自分もとりあえずのhybridをつかってますが、このお話を聞いて自分でも作りたくなってきました。
あとスライドが非常にキレイでした。


## vmp: the most ambitious vim emulator

[@t9md](https://twitter.com/t9md)さんによる、Atom上のVimプラグインのお話です。

https://qiita.com/t9md/items/236d09fea9bcdfabdcea

Vimコマンドの「動詞句」「目的語」のお話どっかでも聞いたなーと思ってたら、[去年](https://qiita.com/t9md/items/0bc7eaff726d099943eb)もお話されてました。
自分自体はしばらくAtomを使う予定は無いですが、内部処理のお話は楽しいですし、Atomならではの、ピカピカする感じがキレイでした。
ちなみに[Vim Vixen](https://github.com/ueokande/vim-vixen)は目的語が豊富じゃないので、コマンドの処理はswitch caseで処理してます。

## Vim and Compatibility

[@senopen](https://twitter.com/senopen)さんによる、どこでも動くVim scriptのお話です。

http://lamsh.github.io/slide/2017/20171104_VimConf2017/index.html

現在はVim/Vim scriptが標準化されてないので、移植性が高いVim scriptを作るにはいろいろ頑張る必要があります。
発表では「Write .vimrc Once, Work Vim Anytime/Anywhere」と言ってましたが、Vimプラグインを作ったときにも同じことを考える必要がありますね。
Vimバージョン固有の機能を使うときは、バージョン・パッチによる条件分岐をするか、必要な前提条件は書いておいたほうがユーザにも優しそうです。

## neosnippet.vim + deoppet.nvim

[@ShougoMatsu](https://twitter.com/ShougoMatsu)さんによる、dark poweredなプラギンのおはなしです。

https://www.slideshare.net/Shougo/neosnippetvim-deoppetnvim-in-vim-conf-2017

「snippet、よくわからないから作る」という行動力と実装力が羨ましいです。
来年にはいい感じにスニペットができるそうです。
あとdeoplete.nvimがVim8に対応したからneocomplete.vimの開発が終了らしいです。

## How ordinary Vim user contributed to Vim

[@dice_zu](https://twitter.com/dice_zu)さんによる、Vimのコントリビュートのお話です。

https://speakerdeck.com/daisuzu/how-ordinary-vim-user-contributed-to-vim

本人は謙遜気味でお話していましたが、Vimにパッチを送って取り込まれているという実績があるので、すごいなぁと思いました。
またVimのバグの再現やコントリビュートまでの手順もしっかりとしていて、参考になりました。

## The new syntax highlighter for Vim

[@p_ck_](https://twitter.com/p_ck_)さんによる、Rubyの複雑な文法に対するシンタックスハイライトについてです。

https://speakerdeck.com/pocke/the-new-syntax-highlighter-for-vim

Vimのシンタックスハイライトは、`start`とか`end`とかでマッチする条件を正規表現で記述できますが（自分も過去に[ちょっとだけ書いたことある](https://github.com/ueokande/balsa-vim/blob/master/syntax/balsa.vim)）、
Rubyの複雑な文法ではうまく対応できないということでした。
ということでRubyパーサーのRipperでRubyのコードを解析していい感じにハイライトするというお話でした。
これTalk showで「ASTでsyntax highlight書けるようにしたい」ってお話が出て、まさにコレだなーと思いました。
ただRubyがわでsyntax groupを割り当てるなどインターフェイスがまだVimと連携できる感じではなさそうだったのですが、今後の発展にも期待です。

## You've been Super Viman. After this talk, you could say you are Super Viman 2 -- Life with gina.vim

[@lambdalisue](https://twitter.com/lambdalisue)さんによる、[Gina.vim](https://github.com/lambdalisue/gina.vim)のお話です。

https://lambdalisue.github.io/vimconf2017/assets/player/KeynoteDHTMLPlayer.html

`git add`とか`git diff`とかのゴニョゴニョする処理を、Vimでできるプラグインです。
たしかに自分の場合もgit commitする前の段階や、履歴を追うだけで妙に時間かかってました。
ちょっと入れてみます。

## 来年までの自分のトライ

- .vimrcをいい感じにする ... Vim熱が覚めないうちにVimります。
- 登壇できるレベルにはVim貢献・Vimプラグインを作る ... Vim熱が覚めないうちに
- 弊社からスポンサーになる ... 今年は企業スポンサーが多かったですが、それでも赤字だそうなので、ちょっと来年にむけて頑張ってみます

