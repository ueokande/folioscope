---
title: URLをHTMLタグに置換する
date: 2011-01-03T03:16:10+09:00
tags: [C/C++, Qt]
---

QStringでURLをHTMLタグに置換するには, QRegExpとQString::replace\(\)メソッド用いることで可能です  
QString::replace\(\)は検索時のcapturing\-parenthesesを\\1, \\2, \.\.\.で参照することができます\.

Qt 4\.7\.1: QString Class Reference  
[http://doc\.qt\.nokia\.com/latest/qstring\.html\#replace\-16](http://doc.qt.nokia.com/latest/qstring.html#replace-16)  
Qt 4\.7\.1: QRegExp Class Reference  
[http://doc\.qt\.nokia\.com/latest/qregexp\.html\#capturing\-parentheses](http://doc.qt.nokia.com/latest/qregexp.html#capturing-parentheses)

正規表現は次のURLより  
Perlメモ  
[http://www\.din\.or\.jp/~ohzaki/perl\.htm\#URI](http://www.din.or.jp/~ohzaki/perl.htm#URI)

```cpp
QString text = <URL source>;
QRegExp exp("(s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)");
text.replace(exp, "<a href=\"\\1\">\\1</a>");
```

