---
title: VagrantでAnsibleを加速させる
date: 2017-07-04 21:00 JST
---

![Vagrant, Docker and Ansible](vagrant-docker-ansible.png)

Ansibleなどのプロビジョニングスクリプトを同じホストに何度も適用していると、そのスクリプトが正しく動くのか怪しくなってきます。
新規環境で流すと実は動かなかったりなんて。
この記事では**コンテナを使って高速に環境を再作成**することで、いつも正しく動くプロビジョニングスクリプトを記述する方法を紹介します。
Vagrant用が生成する`ssh_config`をAnsibleに渡すので、**Ansibleのinventoryファイルを編集せずにデプロイ先をコンテナに切り替える**ことができます。
`Vagrantfile`およびAnsible playbooksはGitHubで公開しています。

![github][ueokande/ansible-vagrant-playground]

この記事では、例としてAnsibleでElasticsearchクラスタを構築します。
また高速化のためにaptキャッシュサーバも配置します。
`Vagrantfile`によって以下のホストを作成します。

- `apt-cacher`: aptキャッシュサーバ
- `elasticsearch-client` Elasticsearchのクライアントノードで、クラスタのエンドポイントとなる
- `elasticsearch-master-{n}` Elasticsearchのマスターノード
- `elasticsearch-data-{n}` Elasticsearchのデータノード

`apt-cacher`の構築はAnsibleの対象ではないので、`Dockerfile`で環境を作ります。
各Elasticsearchノードは、SSHができる環境を`Dockerfile`で作ります。

コンテナを定義する
------------------

ますはじめに、Dockerの[Embedded DNS server](https://docs.docker.com/engine/userguide/networking/configure-dns/)を使うために、ネットワークを定義します。

```sh
docker network create elasticsearch
```

このネットワークに接続したコンテナは、コンテナ名で他のコンテナの名前解決できるようになります。

### Vagrantfileを記述

Vagrantfileの全貌は以下のとおりです。

```ruby
# Vagrantfile
def vanilla_container(config, name, &proc)
  config.vm.define name do |node|
    node.vm.provider "docker" do |docker|
      docker.name = name
      docker.create_args = ["--hostname=#{name}", "--network=elasticsearch"]
      docker.build_dir = "vanilla"
      docker.has_ssh = true

      proc.call(docker) if block_given?
    end
  end
end

Vagrant.configure("2") do |config|

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.define "apt-cacher" do |node|
    node.vm.provider "docker" do |docker|
      docker.name = "apt-cacher"
      docker.create_args = ["--hostname=apt-cacher", "--network=elasticsearch"]
      docker.build_dir = "apt-cacher"
    end
  end

  (1..4).each do |i|
    vanilla_container config, "elasticsearch-master-#{i}"
  end
  (1..6).each do |i|
    vanilla_container config, "elasticsearch-data-#{i}"
  end
  vanilla_container config, "elasticsearch-client" do |docker|
    docker.expose = [9200]
  end
end
```

さきほど作成したネットワークにコンテナを接続するために、`docker.create_args`に`--network=elasticsearch`を指定します。
そしてコンテナ名を`docker.name`で指定して、ホスト名を`docker.create_args`に`--hostname=apt-cacher`を追加することで設定します。
今回はElasticsearchノードのコンテナをヘルパメソッドでガッと定義します。
エンドポイントとなる`elasticsearch-client`ノードは、ポート9200をexposeします。

### `vanilla`コンテナの定義

`vanilla`のDockerfileは、実際のAnsibleのターゲットホストに近い状態を作るため、必要最低限の環境を構築します。
sudoやsshサーバの設定については、[Vagrant Docker providerでSSHができるまで](http://localhost:4567/2017/07/01/vagrant-docker-provider/)をどうぞ。
また`apt-cacher`をaptのキャッシュサーバとしてプロキシに設定します。

```sh
# vanilla/Dockerfile
FROM ubuntu:16.04

RUN apt update && apt install -y --no-install-recommends \
      openssh-server \
      sudo \
      ca-certificates \
      apt-transport-https \
      python \
      curl

# vagrantユーザを追加
RUN useradd --create-home --user-group vagrant && \
    echo -n 'vagrant:vagrant' | chpasswd && \
    echo 'vagrant ALL=NOPASSWD: ALL' >/etc/sudoers.d/vagrant

# apt-cacherをプロキシに設定
RUN echo 'Acquire::http::Proxy "http://apt-cacher:3142/";' >/etc/apt/apt.conf.d/02proxy

RUN mkdir -p /var/run/sshd
CMD /usr/sbin/sshd -D
```

### `apt-cacher`コンテナの定義

`apt-cacher`コンテナは、aptキャッシュのみを行うので、sshサーバやsudoすら必要ありません。
`CMD`で`apt-cacher-ng`を起動する、シンプルなコンテナです。

```sh
# apt-cacher/Dockerfile
FROM ubuntu:16.04
RUN apt update && apt install -y --no-install-recommends \
      ca-certificates \
      apt-cacher-ng

VOLUME "/var/cache/apt-cacher-ng"

RUN mkdir -p /var/run/apt-cacher-ng
CMD /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng foreground=1
```

コンテナを起動する
------------------

この状態でコンテナを立ち上げてみましょう

```sh
vagrant up
```

`vagrant ssh`で各ホストにログインできるので、他のホストの名前が引けるか、apt-cacherが正常に動作しているかを確認してみましょう。

```sh
vagrant ssh elasticsearch-client -- getent hosts elasticsearch-master-1
vagrant ssh elasticsearch-client -- sudo apt update
```

Ansibleを流す
-------------

Ansible playbookは平凡なElasticsearchクラスタを構築するのみです。
詳しくはを[リポジトリ](https://github.com/ueokande/ansible-vagrant-playground/tree/master/ansible)を参照してください。

次にAnsibleを流すために、`ssh_config`を作ります。
引数なしの`vagrant ssh-config`だと、`apt-cacher`の設定も作ろうとして失敗するため、`apt-cacher`を除いたホストを指定してssh_configを作ります。

```sh
vagrant status | \
    awk '/running/ { print $1 }' | \
    grep -v 'apt-cacher' | \
    xargs -n1 vagrant ssh-config >ssh_config
```

そして`ssh_config`をAnsibleに渡すために、`ansible.cfg`を作ります。

```sh
cat >ansible.cfg <<EOF
[ssh_connection]
ssh_args = -F ssh_config
EOF
```

そして流します。

```sh
ansible-playbook --inventory-file=ansible/inventories/hosts --sudo ansible/site.yml
```

出来上がったらクライアントノードからクラスタの状態を見てみましょう。`number_of_nodes`が11、`number_of_data_nodes`が6となっていれば正常にクラスタが作成できています。

```sh
client_ip=$(docker inspect elasticsearch-client  | \
    jq -r '.[].NetworkSettings.Networks.elasticsearch.IPAddress')
curl http://${client_ip}:9200/_cluster/health | jq '.'
```
