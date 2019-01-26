---
title: zypperを使ってパッケージにパッチをあててインストール
date: 2014-10-02T13:32:11+09:00
tags: [openSUSE]
---

多くのLinuxディストリビューションがそうであるように、openSUSEのリポジトリには、パッケージのソースコードも含まれています。
幸いopenSUSEのZypperは、バックエンドにRPMを使用しているので、
基本的な手順はRPMのビルドとほとんど変わりません。

基本的な流れは次のとおりです。

0. src\.rpmをダウンロード
1. ソースコードに変更点を加え、 変更前との差分をパッチ化
2. rpmを作成してインストール

rootでのビルドはトラブルのもとなので、
パッチを当てる作業などは一般ユーザーで行い、
パッケージのインストール時のみに管理者権限を発動します。

# 環境を揃える

まずRPMを構築するためのrpm\-buildパッケージをインストールします。

```
$ sudo zypper in rpm-build
```

つぎに、RPMの構築に必要なディレクトリを作成します。

```
$ mkdir -p ~/rpmbuild/{SOURCES,SPECS,BUILD,RPMS,SRPMS}
```

それぞれのディレクトリの役割は、次のとおりです。

<dl>
<dt>SOURCES</dt>
<dd>アーカイブ化されたソースやパッチファイルがあるところ。</dd>
<dt>SPECS</dt>  <dd>RPMの生成手順などが記述されるSPECファイルがあるところ。</dd>
<dt>BUILD</dt>  <dd>展開されたソースファイルが置かれるところ。</dd>
<dt>RPMS</dt>   <dd>.rpm形式の、コンパイル済みのバイナリパッケージが置かれるところ。</dd>
<dt>SRPMS</dt>  <dd>.src.rpm形式の、ソースパッケージが置かれるところ。</dd>
</dl>

# ソースをダウンロード

ソースコードは`source-install`オプションでインストールされます。

```
$ sudo zypper source-install package_name
```

これでパッケージのソースコードと、ビルドに必要なパッケージがインストールされました。ソースコードは`/usr/src/packages/`以下にrpmbuild可能な形で提供されます。

次にユーザがrpmbuild可能なよう、先ほど作成したディレクトリに、ビルドに必要なファイルのリンクを貼ります。
まずビルドに必要なソースコードおよびパッチのシンボリックリンクを、`~/rpmbuild/SOURCES`以下に作成します。

```
$ ln -s /usr/src/packages/SOURCES/package_name* ~/rpmbuild/SOURCES
```

そして\.specファイルを、`~/rpmbuild/SPEC`以下にコピーします。

```
$ cp /usr/src/packages/SPECS/package_name.spec ~/rpmbuild/SPECS
```

# パッチの作成

パッチをWeb上から拾ってきた人は、`BUILD`ディレクトリに配置してここのステップは終了。ソースコードを自分で編集する人は、パッチを自作して`SOURCE`ディレクトリに配置します。

まずソースコードを展開して、提供されているパッチをすべて適用します。

```
$ rpmbuild -bp SPECS/package_name.spec
```

展開されパッチを当てられたソースコードは、`BUILD`に展開されます。
差分をとる必要があるので、`BUILD`内にあるソースコードをコピーします。

```
$ cd ~/rpmbuild/BUILD
$ cp -r package_name package_name.modify
```

ソースコードの変更を終えると、変更前とdiffして`SOURCE`ディレクトリにパッチを作成します。

```
diff -aurN package_name package_name.modify > ../SOURCE/additional_feature.diff
```

# SPECファイルの変更

作成したパッチをソースコードに適用するように、\.specに追記します。

```
Source: ...
BuildRoot: ...
Patch99: add-share.patch

...

%prep
%setup ...
%patch99 -p1
```

# ビルド & インストール

これですべての準備ができました。
あとはソースコードをビルドしてRPMを作成するだけ。

```
$ rpmbuild -ba SPECS/package_name.spec
```

あるいはバイナリパッケージのみで良かったら、`-bb`オプションで。

```
$ rpmbuild -bb SPECS/package_name.spec
```

ビルドが完了すれば、BUILD以下に\.rpmができているはずなので、インストールです。

```
$ sudo zypper in package_name.rpm
```

# 参考

- [https://activedoc\.opensuse\.org/de/node/1513\#sec\.zypper\.softman\.sources](https://activedoc.opensuse.org/de/node/1513#sec.zypper.softman.sources)
- [http://d\.hatena\.ne\.jp/cactusman/20080315/p1](http://d.hatena.ne.jp/cactusman/20080315/p1)
- [http://bradthemad\.org/tech/notes/patching\_rpms\.php](http://bradthemad.org/tech/notes/patching_rpms.php)

