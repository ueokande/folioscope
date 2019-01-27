---
title: 新しいディスプレイサーバへの期待と不安
date: 2013-07-15T22:56:15+09:00
tags: [Linux, コラム・雑談]
---

長らくUnix系OSで使われてきたX Window Systemにも限界が来ており，新しいディスプレイサーバであるWaylandやMirの開発が活発になっている．最近では[Phoronix](http://www.phoronix.com/)でもWaylandやMirの話で持ちきりである．しかし新しい時代への期待が高まる中，同時に新しい時代への不安も高まる．

KDEやGnomeといった近代的なデスクトップ環境はすでにWaylandに対応しており，これらはすでに新しいプロトコルへの移行の準備は整っている．しかし取り残されたアプリケーションはどうなるのか．私は現在awesomeというWindow Managerを使用しているが，awesomeは直接X11のライブラリを使用している．おそらくはXWaylandやXMir上で動作するが，Window Managerとしての役割を果たすかは謎である．

勝手な偏見ではあるが，硬派なWindow ManagerのコミッタたちはWaylandやMirへの移行はしばらく行わないと予想する．WaylandやMirの時代が来るのはまだ先であるが，それまでに新たな手を打たなければならない．

