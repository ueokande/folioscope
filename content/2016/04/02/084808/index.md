---
title: LEDでモールス信号
date: 2016-04-02T08:48:08+09:00
tags: [C/C++, Linux]
---

LEDでモールス信号を出力するプログラムを作りました。

[Morse Code for LED in Linux · GitHub](https://gist.github.com/ueokande/aa8127f052532de8d613d91867618fb0)

sysfsなどに出力すると、コンピュータのLEDを使ってモールス信号を送ることができます。

```sh
echo 'Hello World, Goodbye' | a.out >/sys/class/leds/input0\:\:capslock/brightness
```

