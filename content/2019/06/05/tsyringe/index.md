---
title: TSyringe - JavaScript/TypeScript向けの軽量DIコンテナ
date: 2019-06-05T21:00:00+09:00
tags: [Vim Vixen, TypeScript]
---

Vim VixenではClean Architecture風の設計をしており、扱うモデルやレイヤー毎にクラスを作成します。
現在はクラス数が100を超えて、クラスにインスタンスをいちいち渡したり、インスタンスの作成と管理が面倒になってきました。
そこでVim VixenではDependency Injection (DI)コンテナを導入することにしました。

いろいろ探してみると、すでにJavaScript/TypeScript用のDIコンテナがいくつか存在するようです。
その中で（巨人の肩に乗るつもりで）Microsoftの「TSyringe」という軽量DIコンテナを採用しました。

{{<github src="microsoft/tsyringe">}}

TSyringeはデコレーター（Javaのアノテーションのようなもの）でDIするクラスを指定したり、必要なクラスをコンストラクタで受け取れます。

## セットアップ

まずは`tsyringe`本体と、reflectを扱うためのpolyfillパッケージ`reflect-metadata`をインストールします。

```console
$ npm install --save tsyringe reflect-metadata
```

TSyringeを使うにはTypeScriptのコンパイルオプションでデコレーターを有効にする必要があります。
以下の2つのオプションを`tsconfig.json`で有効にします。

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  }
}
```

そして`reflect-metadata`パッケージをトップレベルのスクリプトでimportします。

```typescript
// index.ts
import 'reflect-metadata';
```

## 使えるデコレーター

利用できるデコレーターは4つです。

- `@injectable()`
- `@singleton()`
- `@autoInjectable()`
- `@inject()`

### `@injectable()`

クラスをインジェクト可能なオブジェクトとしてDIコンテナに登録します。
コンストラクタのパラメータに、依存するクラスを受け取ることができます。
DIコンテナは自動で、コンストラクタに渡すべきインスタンスを作成したり、DIコンテナから取り出します。

```typescript
import { injectable } from 'tsyringe';

@injectable()
class UserRepository {
  constructor(private sqlDriver: SQLDriver) {}
}

@injectable()
class UserUseCase {
  constructor(private userRepository: UserRepository) {}
}
```

```typescript
import { container } from 'tsyringe';

// container.resolve() でクラスのインスタンスを解決する
let userUseCase = container.resolve(UserUseCase);
```

### `@singleton()`

クラスをインジェクト可能なシングルトンオブジェクトとしてDIコンテナに登録します。

```typescript
import { singleton } from 'tsyringe';

@singleton()
class UserClientFactory {
  constructor() {}
}
```

### `@autoInjectable()`

コンストラクタをパラメータを自動で解決して、パラメータ無しのコンストラクタ呼び出しを可能にします。
これはDIコンテナからではなく`new`でオプジェクトを作成できるようになります。

```typescript
import { autoInjectable } from 'tsyringe';

@autoInjectable()
class UserUseCase {
  constructor(private userRepository?: UserUseCase) {}
}

let userUseCase = new UserUseCase();
```

### `@inject()`

コンストラクタのパラメータをクラス名ではなく**トークン**を使って解決します。
例えば文字列を指定してクラスのインスタンスを解決できます。

```typescript
import { inject } from 'tsyringe';

class UserUseCase {
  constructor(@inject('UserRepository') private userReository: UserRepository) {}
}
```

```typescript
import { container } from 'tsyringe';

// for test
container.register('UserRepository', { useClass: MockUserRepository })

// for production
container.register('UserRepository', { useClass: UserRepositoryImpl })
```

## 例: チケット販売管理

チケット販売システムを作ります。
チケットを購入すると、在庫から1枚チケットが減ります。
在庫のチケット枚数がゼロの場合はチケット購入に失敗したことがわかり、在庫の枚数はゼロのままです。

以下のようなクラスを定義します。

- `TicketRepository`: チケットを管理する永続化層。ここでは簡易化のためにオンメモリに記録する。
    - `getStock(): number`: 現在の在庫数を取得
    - `setStock(x: number): void`: 在庫数を更新
- `TicketUseCase`: チケットを販売するビジネスロジック
    - `buy(): boolean`: チケットを購入する。購入できたら在庫数から1減らして`true`を返す。購入できなければ`false`を返す。

まずは`TicketRepository`の実装です。
グローバル変数のチケット枚数を取得したり更新できます。

```typescript
// TicketRepository.ts
import { injectable } from 'tsyringe';

let stock: number = 5;

@injectable()
export default class TicketRepository {
  getStock(): number {
    return stock;
  }

  setStock(newValue: number): void {
    stock = newValue;
  }
}
```

続いてチケットを販売するビジネスロジックの記述です。
`TicketUseCase`ではチケットの在庫にアクセスするため、`TicketRepository`のインスタンスをコンストラクタで受け取ります。
今は平行処理とか気にせず雑に実装します。

```typescript
// TicketUseCase.ts
import { injectable } from 'tsyringe';
import TicketRepository from './TicketRepository';

@injectable()
export default class TicketUseCase {
  constructor(private ticketRepository: TicketRepository) {}

  buy(): boolean {
    let current = this.ticketRepository.getStock();
    if (current === 0) {
      return false;
    }
    this.ticketRepository.setStock(current - 1);
    return true;
  }
}
```

最後にトップレベルの記述です。

```typescript
// index.ts
import 'reflect-metadata';
import { container } from 'tsyringe';

import TicketUseCase from './TicketUseCase';

let usecase = container.resolve(TicketUseCase);

while (usecase.buy()) {
  console.log('bought ticket');
}
console.log('ticket sold out!');
```

`TicketUseCase`のインスタンスは`new`で作成せずに`container.resolve()`で取得できます。
`TicketUseCase`のコンストラクタのパラメータへの渡し方や、`TicketRepository`と`TicketUseCase`のインスタンスの作成などは全てDIコンテナに任せることができました。

## TypeScript interface

TypeScriptのinterfaceを扱うには工夫が必要です。
interfaceは型情報の実体は持たないため（実行時にはクラスがinterfaceを実装してるかわからない）、TSyringeではうまく扱えません。
そのためデコレータを使うのではなく、明示的にトークンを付与して実装クラスをDIコンテナに登録します。
そして実装クラスの取得も、`@inject()` デコレータを使って登録時のトークンで参照します。

たとえば先程の例で、`TicketRepository`をインターフェイス化して、その実装を`TicketRepositoryImpl`に分離します。

```typescript
// TicketRepository.ts
export default interface TicketRepository {
  getStock(): number;

  setStock(newValue: number): void;
}
```

```typescript
// TicketRepositoryImpl.ts
import TicketRepository from './TicketRepository';

export default class TicketRepositoryImpl implements TicketRepository {
  // ...
}
```

`TicketRepository`を使う側は、コンストラクタではinterfaceで受け取ります。
そしてDIコンテナから取り出すときに文字列トークン`'TicketRepository'`を使用します。

```typescript
// UserUseCase.ts
import { injectable, inject } from 'tsyringe';
import TicketRepository from './TicketRepository';

@injectable()
export default class TicketUseCase {
  constructor(
    @inject('TicketRepository') private ticketRepository: TicketRepository,
  ) {}

  // ...
}
```

アプリケーション起動時には実装クラス`TicketRepositoryImpl`クラスを、トークン`'TicketRepository'`で登録します。
これで`TicketUseCase`のコンストラクタには、`TicketRepositoryImpl`のインスタンスオプジェクトが渡ります。

```typescript
// index.ts
import 'reflect-metadata';
import { container } from 'tsyringe';
import TicketRepositoryImpl from './TicketRepositoryImpl';
import TicketUseCase from './TicketUseCase';

// TicketRepositoryの登録
container.register('TicketRepository', { useClass: TicketRepositoryImpl })

let usecase = container.resolve(TicketUseCase);
```

少しくどい書き方に感じますが、インターフェイスと実装を分けることで、状況に応じて実装クラスを切り替えることができるようになります。
たとえばプロダクションでは`TicketRepositoryImpl`を利用して、テスト時にはモック実装を使うといったことができます。。
Clean Architectureの原則でもビジネスロジック(Use case)ではRpeositoryの実装に依存してはいけません。

## まとめ

TSyringeの使い方を簡単に紹介しました。
ここでは簡単な例だったので、その利便性は実感しにくいかも知れません。

Vim Vixenでは100を超えるクラス間の依存性の注入にTSyringeを使いました。
そしてClean ArchitectureやDDDなどのクラス間の依存が多くなると、DIコンテナはパワーを発揮します。
