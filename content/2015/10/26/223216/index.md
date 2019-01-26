---
title: RailsプラグインのテストのためのテストRailsプロジェクト
date: 2015-10-26T22:32:16+09:00
tags: 
---

Railsのプラグインを開発するときには、テスト用のRailsプロジェクトが必要になりますね。
そこでテスト用のRailsプロジェクトをプロジェクトのサブディレクト以下に作成して、specからRailsアプリをテストできるようにします。

ディレクトリ構成は以下のとおりです。

```sh
/    # project root
├── Gemfile
├── lib    # プロジェクトの本体
└── spec
    ├── rails_app/    # Railsアプリのディレクトリをspec以下に
    ├── spec_helper.rb
    └── rails_app_spec.rb
```

Railsアプリの場所はどこでもいいですけど、テスト時に使うのでspec以下が妥当だと思います。

## bundle install

まずGemfileを書きます。rails環境も開発・テスト環境でしか使わないので、`:development, :test` グループに放り込みます。

```ruby
# Gemfile
source "https://rubygems.org"

group :development, :test do
  gem 'rspec'
  gem 'rails', '4.2.4'
  gem "sqlite3"
end
```

その後は通常通り `bundle install` します。

## Railsアプリの作成 

ここまででrailsコマンドが使えるので、spec以下にRailsアプリをnewします。
Gemfileやbundleも必要無いので、オフにします。

```sh
bundle exec rails new --skip-bundle --skip-gemfile spec/rails_app
```

これでサブディレクトリにRailsアプリができました。rails consoleやdb:migrateするときも、rails\_appに移動してから通常のRailsプロジェクトと同じように実行できます。
以上でRailsアプリ側の準備は完了です。

## RSpecの設定

つづいてspecを書いてゆきます。まず `spec_helper.rb` に、先ほど作ったRailsの環境をロードするために、次の2行を書きます。

```ruby
# spec/spec_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../rails_app/config/environment', __FILE__)
```

これでspec\_helperをrequireしたテストは、RSpec時にRails環境がロードされます。
確認のためにRailsを使用した簡単なspecを書きます。

```ruby
# spec/rails_app_spec.rb
require 'spec_helper'

RSpec.describe 'Rails app project' do
  describe 'Rails environment setup' do
    subject { Rails.root.to_s }
    it { should match %r(spec/rails_app) }
  end
end
```

そして通常通りRSpecを走らせて、テストがパスするか確認します。

```sh
bundle exec rspec
```

## 補足 : Rakeタスクのロード

Rakefile内でテスト用RailsアプリのRakefileをロードすることで、Railsアプリ用Rakeタスクも実行できます。

```ruby
# Rakefile 
namespace 'rails_app' do
  load File.expand_path('../spec/rails_app/Rakefile', __FILE__)
end
```

```sh
bundle exec rake rails_app:db:migrate  # DBマイグレート
```

