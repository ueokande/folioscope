---
title: JVMのヒープサイズとコンテナ時代のチューニング
date: 2019-08-15T22:00:00+09:00
tags: [Java]
---

最近JVMのヒープ領域とパラメータ、そしてコンテナの関係について調べてました。
案外まとまった情報が少なかったので簡単にまとめました。

## Javaのヒープサイズを設定

まずはJavaのヒープサイズについて簡単なおさらいです。

本番環境でJavaアプリケーションを運用する上で、JVMのヒープサイズを決定するのは非常に大事なポイントです。
ヒープ領域の最大サイズを大きくすればガベージコレクション (GC) の回数は減らすことができますが、
必要以上に大きくしすぎると無駄にリソースを消費したり、OOM killerでOSにプロセスを終了させられます。

JVMが使用できるヒープサイズは、Java APIの `Runtime.getRuntime().maxMemory()` で確認できます。
また `java` の起動オプションに `-XX:+PrintFlagsFinal` オプションを付与すると、JVMの各種パラメータを取得できます。
この記事では後者の `-XX:+PrintFlagsFinal` オプションで取得する方法で解説を進めます。
また実行するJavaプログラムが無くても、`-version`オプションでJVMのパラメータを確認できます。

```console
$ java -XX:+PrintFlagsFinal -version
[Global flags]
     intx ActiveProcessorCount                      = -1                                  {product}
    uintx AdaptiveSizeDecrementScaleFactor          = 4                                   {product}
    uintx AdaptiveSizeMajorGCDecayTimeScale         = 10                                  {product}
    uintx AdaptiveSizePausePolicy                   = 0                                   {product}
    uintx AdaptiveSizePolicyCollectionCostMargin    = 50                                  {product}
...
```

JVMのヒープサイズを設定するには、手動による明示的な設定と実行環境から自動に設定する2つの方法があります。
まずはそれぞれの方法について紹介します。

### ヒープサイズの明示的な指定

明示的にヒープサイズを設定するには、MaxHeapSizeパラメータを設定します。
このパラメータはJVMが確保するJavaヒープの最大サイズです。
世代別GCの場合、New領域やOld領域の合計値がこの値を超えないようになります。

MaxHeapSizeパラメータを設定するには、`java`コマンドに`-XX:MaxHeapSize`または`-Xmx`オプションを指定します。
メモリサイズの後ろに`m`を付けると、MB単位で指定できます。
次の例はMaxHeapSizeを2048MBに設定します。
設定されたMaxHeapSizeは`-XX:PrintFlagsFinal`の結果から確認できます。

```console
$ java -XX:MaxHeapSize=2048m -XX:+PrintFlagsFinal -version 2>/dev/null | grep -w MaxHeapSize
    uintx MaxHeapSize                              := 2147483648                          {product}
```

### ヒープサイズの自動設定

MaxHeapSizeを設定しない場合は、JVMは実行環境からピープサイズを決定します。
メモリがたくさんある環境では、より大きなヒープサイズが利用できます。
ヒープサイズは次の表に基づいて計算されます。

| メモリサイズ M          | ヒープサイズ
|---                      |---
| M &le; 248m             | M / 2
| 248m &lt; M &le; 496m;  | 124m
| 496m &lt; M             | M / 4

境界値の248mや496mは124mの倍数です。
かなり中途半端な数字ですが、これは32bit版では96mでしたが、64bit版では少し余分にヒープ領域が必要になるので若干大きくなったためです（詳しくは[JDK-4967770][]）。

自分の手元でMaxHeapSizeを指定しない場合は以下のとおりになりました。
自分の環境は32GBメモリなので、その1/4の8GBがヒープ領域として利用できます。

```java
$ java -XX:+PrintFlagsFinal -version 2>/dev/null | grep -w MaxHeapSize
    uintx MaxHeapSize                              := 8415870976                          {product}
```

### コンテナ環境での問題

MaxHeapSizeは実行環境にあわせていい感じにヒープサイズを設定するように見えます。
ただしコンテナだと少し事情が違います。

コンテナではカーネルのCGroupという機能を使って、コンテナ内のプロセスが利用できるメモリを制限できます。
しかしコンテナ上でメモリサイズを取得しても、見えるのはコンテナホスト側のメモリサイズです。
コンテナ内で`free`コマンドを打つと、なぜかホスト側のメモリサイズが表示されるといった経験をしたことがある人もいるでしょう。

```console
$ docker run --memory 1024m --rm busybox free -m
              total        used        free      shared  buff/cache   available
Mem:          32099        4416       21111         295        6571       27414
Swap:          8188           0        8188
```

この問題を解決するために、メモリサイズではなくCGroupからヒープサイズを取得するオプションがJava 9から追加されました。

## コンテナ上でのメモリ領域の判定

UseCGroupMemoryLimitForHeapというオプションを使うと、ヒープサイズをメモリサイズではなくCGroupのメモリ制限値から設定します。
しかしJava 10以降を使ってるなら、 UseCGroupMemoryLimitForHeapを**使うべきではありません**。
このオプションは後述のUseContainerSupportオプションで置き換えられ、Java10からはdeprecatedになりました。

もう1つのコンテナアプリケーションの特徴に、VMと違い1コンテナで1アプリケーションを動かすことが多くなりました。
KVMなどの実行環境では、Javaプロセス以外のOSプロセスやデーモンプロセスが立ち上がってることがほとんどです。
一方コンテナアプリケーションでは、コンテナ内で1プロセスのみ立ち上がるということもあります。
そのためコンテナが利用可能なメモリ容量の殆どをヒープ領域に割り当てることができます。

### UseCGroupMemoryLimitForHeap (deprecated)

UseCGroupMemoryLimitForHeapはJava 9に追加されたオプションです（[JDK-8170888][]）。
またJava 8u121などにもバックポートされました。
CGroupのメモリの制限値は、コンテナ内では `/sys/fs/cgroup/memory/memory.limit_in_bytes` から確認できます。
UseCGroupMemoryLimitForHeapもこのファイルをチェックして、コンテナが利用できるメモリ容量を取得します。

```console
$ docker run --memory 1024m --rm busybox cat /sys/fs/cgroup/memory/memory.limit_in_bytes
1073741824
```

UseCGroupMemoryLimitForHeapを利用するには、`-XX:+UnlockExperimentalVMOptions`と`-XX:+UseCGroupMemoryLimitForHeap` オプションをJava起動時に渡します。
するとJVMは（ホストの）メモリ容量ではなく、CGroupのメモリ容量を使用します。

```console
# ホストのメモリ容量から計算する
$ docker run --rm --memory 2048mb openjdk:8u181 java -XX:+PrintFlagsFinal -version 2>/dev/null | \
      grep -w MaxHeapSize
    uintx MaxHeapSize                              := 8415870976                          {product}

# CGroupのメモリ容量から計算する
$ docker run --rm --memory 2048mb openjdk:8u181 java -XX:+PrintFlagsFinal \
          -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -version 2>/dev/null | \
      grep MaxHeapSize
    uintx MaxHeapSize                              := 536870912                           {product}
```

しかし先程も述べたとおり、UseCGroupMemoryLimitForHeapオプションは非推奨となり、Java 11では廃止されました。
かわりにJava 10で追加されたUseContainerSupportオプションを利用します。

### UseContainerSupport

UseContainerSupportはJava 10に追加されたオプションです（[JDK-8146115][]）。
またJava 8u191などにもバックポートされました。

UseContainerSupportはCGroupからメモリ制限を取得するだけでなく、次の機能もあります。

- CGroupのCPUの制限値も使用する
- CGropu上のメモリの利用率も取得できる

UseContainerSupportオプションはデフォルトで有効になっています。
そのため特に何も指定しなくても、コンテナが利用できるメモリ容量の1/4がヒープサイズとして割り当てられます。

```console
$ docker run --rm --memory 1024m openjdk:10.0 java -XX:+PrintFlagsFinal -version 2>/dev/null |\
      grep -w MaxHeapSize
   size_t MaxHeapSize                              = 268435456                                {product} {ergonomic}
```

## メモリサイズとヒープサイズの割合を調整する

さて、ここまではヒープサイズはメモリ容量の1/4という仮定で話してきました。
この割合を調整するにはMaxRAMFractionおよびMaxRAMPercentageオプションを利用します。

MaxRAMFractionはJava 10でdeprecatedになりました。
なぜならMaxRAMPercentageの方がより細やかに設定できるようになり、MaxRAMFractionは不要となったためです。

### MaxRAMFraction (deprecated)

MaxRAMFractionはメモリサイズに対するヒープサイズを1/MaxRAMFractionで設定します。
デフォルト値は4なので、特に指定が無ければメモリサイズの1/4がMaxHeapSizeになります。

MaxRAMFractionは `-XX:MaxRAMFraction` オプションで設定できます。
次の例はMaxRAMFraction=8に設定してるので、1024MBの1/8である128MBをヒープサイズに割り当てます。

```console
$ docker run --rm --memory 1024m openjdk:10.0 java \
          -XX:+PrintFlagsFinal -XX:MaxRAMFraction=8 -version 2>/dev/null | \
      grep -w MaxHeapSize
   size_t MaxHeapSize                              = 134217728                                {product} {ergonomic}
```

MaxRAMFractionに対してMinRAMFractionパラメータもあります。
MaxRAMFractionはメモリサイズに対するヒープサイズの上限で、MinRAMFractionはヒープサイズの下限です。
ヒープサイズのサイズとメモリサイズの関係を表で書きましたが、これはMaxRAMFraction=4、MinRAMFraction=2という前提です。
JVMはメモリサイズの1/2から1/4の間でヒープサイズを決定します。

さて、MaxRAMFractionはメモリの大半をヒープサイズに割り当てたいという場合に利用できません。
なぜならMaxRAMFractionは整数しか指定できないためです。
MaxRAMFraction=1にするとメモリの全てをヒープ領域に使うため、ネイティブヒープやページキャッシュに利用できるメモリがなくなります。
なのでMaxRAMFractionの最小値は実質2となり、メモリの高々半分までしかヒープ領域に利用できません。

これではコンテナアプリケーションなど、メモリの大半をヒープ領域に利用したい場合に都合が悪いです。
そのため分数ではなくパーセンテージで指定できるMaxRAMPercentageパラメータが登場しました。

### MaxRAMPercentage

MaxRAMPercentageはJava 10に追加されたオプションです（[JDK-8186248][]）。
同時にMaxRAMFractionはdeprecatedになりました。
MaxRAMFractionはパーセンテージでヒープサイズを指定できるので、MaxRAMFractionで指定できなかった1/2以上の領域をヒープ領域として確保できます。

MaxRAMPercentageは`-XX:MaxRAMPercentage`オプションで指定できます。
次の例はMaxRAMPercentage=75を指定してます。
CGroupのメモリサイズが1024MBなので、75%までの768MBをヒープ領域として利用できます。

```
$ docker run --rm --memory 1024m openjdk:10.0 \
          java -XX:+PrintFlagsFinal -XX:MaxRAMPercentage=75 -version 2>/dev/null |\
      grep -w MaxHeapSize
   size_t MaxHeapSize                              = 805306368                                {product} {ergonomic}
```

## まとめ

さて長くなりましたが、Javaのバージョンとコンテナサポート事情については以下のとおりです。

| Javaバージョン           | メモリ領域の取得            | ヒープサイズの割合
|---                       |---                          |---
| Java 8u121 - Java 8u181  | UseCGroupMemoryLimitForHeap | MaxRAMFraction
| Java 8u191 - Java 8u222  | UseContainerSupport         | MaxRAMFraction
| Java 10 -                | UseContainerSupport         | MaxRAMPercentage

もしもJava 8を利用して、Dockerなどのコンテナ環境を利用してる場合は特に注意が必要です。
なぜならMaxRAMPercentageはJava 8に**バックポートされてない**ので、メモリの1/2以上のヒープサイズは確保できません。
その場合は素朴にMaxHeapSizeを固定値にするか、起動時にシェルスクリプトなどでMaxHeapSizeを決定するのが良いでしょう。

さて、今回珍しくJavaについて探求しましたが、JDKプロジェクトの流れも追えて役に立つ情報が多かったです。
まだまだJava周りは深堀できそうな部分があるので、機会があればまた記事を書きたいと思います。

[JDK-4967770]: https://bugs.openjdk.java.net/browse/JDK-4967770
[JDK-8146115]: https://bugs.openjdk.java.net/browse/JDK-8146115
[JDK-8170888]: https://bugs.openjdk.java.net/browse/JDK-8170888
[JDK-8186248]: https://bugs.openjdk.java.net/browse/JDK-8186248
[Garbage Collector Ergonomics]: https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gc-ergonomics.html
[JDK 10 Release Notes]: https://www.oracle.com/technetwork/java/javase/10-relnote-issues-4108729.html
