---
title: VBAに習うクラス設計
date: 2013-01-23T23:56:16+09:00
tags: [コラム・雑談]
---

オブジェクト指向プログラミングをしていると，大抵クラス設計に悩む．特にデスクトップアプリケーションなどの大規模なプログラムになると，どの程度の粒度でクラスを作るべきか分からなかったりする．例えば車のギアを表すのに，整数型を使うか，一つのクラスを作るか，などである．

またクラス間の関係についての設計も悩みどころである．例えば車と人の関係を示すのに，CarクラスにHumanクラスのインスタンスを保持させるか，HumanクラスにCarクラスのインスタンスを保持させるか，あるいはそれぞれのオブジェクトは互いに関係しないか，など．

こういったクラス設計における問題を解決するのに，私はMicrosoft OfficeのVBAのリファレンスを参考にしている．Power Pointの場合だと，VBAからPower Pointのデータにアクセスするためのクラス群が用意されている．  
[Power Point 2010 Developer Reference](http://msdn.microsoft.com/en-us/library/ff746846(v=office.14).aspx)  
例えば，スライドの情報を格納するクラスに[Slide](http://msdn.microsoft.com/en-us/library/ff747240(v=office.14).aspx)がある．Slideクラスは，配置されているシェイプが入っている[Slide\.Shapes](http://msdn.microsoft.com/en-us/library/ff745594(v=office.14).aspx)プロパティや，スライドにテーマを適用する[Slide\.ApplyTheme](http://msdn.microsoft.com/en-us/library/ff745232(v=office.14).aspx)メソッドなどを持っている．

クラス設計に解などは存在しないが，綿密に設計された大きなシステムと考えれば，Microsoft Officeなどは良いクラス設計がされていると考えられる．

