---
title: Qt Designerを使ってコンテキストメニューを編集する
date: 2011-02-12T23:23:08+09:00
tags: [Qt]
---

コンテキストメニューの項目をコードに書かずにQt Designerで作りたかったのですが未対応なようです  
なので<span style="font-weight:bold;color:#755019;">お下品な方法</span>でQt Designerを使ってコンテキストメニューをデザインしたいと思います

ここでは, Qtのヘルプを表示する"Help"と, アプリケーションを終了する"Exit"というアイテムを作成します  
[![f:id:ibenza:20110212035202p:image](/2011/02/12/20110212035202.png)](http://f.hatena.ne.jp/ibenza/20110212035202)

READMORE
#### デザインする

プロジェクトツリーから「新しいファイルを追加\.\.\.」を選択し, 「Qt デザイナ フォーム」を選択します\.  
フォームテンプレートにメニューらしきものがないので, ひとまずWidgetを選択し, ContextMenuという名前で作成します\.  
そうするとデザイナの画面が表示されますが, 一旦閉じます\.

  
次に作成した\.uiファイルをテキストエディタで開きます\.  
widgetタグのclass属性を"QWidget"から"QMenu"に変更します\.  
またpropertyタグにQMenuに存在しないプロパティがあるので, それらを削除します\.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>ContextMenu</class>
 <widget class="QMenu" name="ContextMenu">
 </widget>
 <resources/>
 <connections/>
</ui>
```

先ほどの\.uiファイルを再びQt Designerで開くと, 少し表示が狂ったデザインフォームが表示されますが, 気にせず続けます\.  
まずアクションエディタで"Help"と"Exit"というアクションを追加します\.  
デザイナフォームからフォーカスが失われるとメニューが消えることがあるので, ファイルを保存して開きなおしてください\.  
アクションエディタからデザイナフォーム内へアクションをD&Dすればアクションが追加されます\.

#### オブジェクトを作る

まずQMenuクラスをプロトタイプ宣言し, メンバにQMenu \*menuを追加します\.  
そしてコンストラクタでオブジェクトを作成します\.

  
次にUi::ContextMenuクラスをプロトタイプ宣言し, メンバにUi::ContextMenu \*menu\_uiを追加します\.  
そしてuiのヘッダファイルをインクルードし, コンストラクタでオブジェクトの作成とデストラクタでオブジェクトの解放を行います\.  
これは通常のuiと一緒ですね\.

  
そしてコンストラクタでsetupUiを呼び出し, <span style="font-weight:bold;">引数にQMenuのオブジェクトを指定</span>してレイアウトを適用します\.

```cpp
menu_ui->setupUi(menu);
```

#### メニューの実装

ヘルプを表示するonShowHelp\(\)スロットメソッドを作成します\.

```cpp
void MainWindow::onShowHelp()    // [slot]
{
	QMessageBox::aboutQt(this);    // Qtヘルプの表示
}
```

そしてメニューが選択された時のイベントと終了のイベントをconnectします\.

```cpp
connect(menu_ui->actionHelp, SIGNAL(triggered()), SLOT(onShowHelp()));
connect(menu_ui->actionExit, SIGNAL(triggered()), SLOT(close()));
```

最後にQWidget::contextMenuEvent\(\)メソッドをオーバーライドしてメニューを表示させます\.

```C++
void MainWindow::contextMenuEvent(QContextMenuEvent *event)
{
	menu->exec(event->globalPos());
}
```

#### おわりに

デザイナのつかい方が非公式だから編集できたものじゃないですね  
\.uiファイルの記法を知ってればファイルを直接編集すればいいかも  
早くコンテキストメニューに対応しないかな

