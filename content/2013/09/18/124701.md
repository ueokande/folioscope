---
title: JSON on Qt 5
date: 2013-09-18T12:47:01+09:00
tags: [C/C++, Qt]
---

JSONは素晴らしいデータ構造で，シンプルながら人間にもわかりやすいデータ構造です．
喜ばしいことにQt 5からもJSONライブラリが追加されました．

[QtCore 5\.0: JSON Support in Qt | Documentation | Qt Project](http://qt-project.org/doc/qt-5.0/qtcore/json.html)

使用するクラスも見事にシンプルで，JSONの出力は次のクラスのみで実装できます．

- **QJsonObject** JSONオブジェクトを扱うクラス．JSONオブジェクトは`{`と`}`で囲われたキーとJSON値から成る連想配列のこと．
- **QJsonArray** JSON配列を扱うクラス．JSON配列とは`[`と`]`で囲われたJSON値の配列である．
- **QJsonValue** JSON値を扱うクラス．JSON値とは文字列，数値，JSONオブジェクトやJSON配列も含む．
- **QJsonDocument** JSONのデータ構造を入出力するクラス．

QJsonArrayとQJsonObjectはQJsonValueにもなりえますので，QJsonValueへ変換可能です．

# 簡単な例

QtのJSONライブラリは恐ろしくシンプルで直感的なので．解説がいらないほどですが，使い方を載せておきます．
Qtによる実装は，演算子のオーバーロードを巧みに扱い，よりシンプルに記述することができます．

```cpp
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDate>
#include <iostream>

int main()
{
    QJsonObject person1;
    person1["name"] = QString("yu-na");  // JSONオブジェクトにキー（文字列）と値を追加
    person1["age"] = 15;

    QJsonObject person2;
    person2["name"] = QString("kotomi");
    person2["age"] = 10;

    QJsonArray persons;
    persons.append(person1);  // JSON配列に追加
    persons.append(person2);

    QJsonObject root;
    root["date"] = QDate::currentDate().toString();
    root["persons"] = persons;

    QJsonDocument doc;
    doc.setObject(root);  // ルートオブジェクトを指定
    std::cout << doc.toJson().data();
}
```

出力

```javascript
{
    "date": "Wed Sep 18 2013",
    "persons": [
        {
            "age": 15,
            "name": "yu-na"
        },
        {
            "age": 10,
            "name": "kotomi"
        }
    ]
}
```

