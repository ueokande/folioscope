---
title: Vagrant Docker providerでSSHができるまで
date: 2017-07-01 21:00 JST
---

![Vagrant and Docker](vagrant-and-docker.png)

[Vagrant Docker provider](https://www.vagrantup.com/docs/docker/)を使うと、VagrantからDockerコンテナを起動できます。
VirtualBoxと違いオーバーヘッドが少ないので、もりもり環境を量産できて便利です。

Docker imageが元に環境が構築されるので、Vagrant Boxと違い`vagrant ssh`をするための設定を行う必要があります。
この記事ではVagrant Docker providerで`vagrant ssh`ができるまでの、最小の`Dockerfile`と`Vagrantfile`を紹介します。

Vagrantfile/Dockerfile
----------------------

まず次のような`Vagrantfile`を記述します。
providerに`"docker"`を指定して、ブロック内にDockerの設定を行います。
`build_dir`で`Dockerfile`を含むディレクトリのパスを指定して、`has_ssh`オプションでコンテナでSSHが走っているかどうかを指定します。
`config.ssh`でSSHの認証情報を指定して、Vagrantがコンテナにログインして鍵の埋め込みなどを行えるようにします。
他のオプションについては[公式ドキュメント][docker-configuration]をどうぞ。

```ruby
Vagrant.configure("2") do |config|

  # SSHの認証情報
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.define "hello-docker-provider" do |node|
    node.vm.provider "docker" do |docker|
      docker.build_dir = "."  # Dockerfileを含むディレクトリ
      docker.has_ssh = true   # コンテナはSSHが走ってるか
    end
  end
end
```

続いて`Dockerfile`です。
`openssh-server`と`sudo`をインストールします。
そして`Vagrantfile`で指定したユーザとパスワードを設定して、`sudo`できるよう設定します。
最後に、`sshd`を`CMD`で起動します。

```Dockerfile
FROM ubuntu:16.04
RUN apt update && \
    apt install -y --no-install-recommends openssh-server sudo

RUN useradd --create-home --user-group vagrant && \
    echo -n 'vagrant:vagrant' | chpasswd && \
    echo 'vagrant ALL=NOPASSWD: ALL' >/etc/sudoers.d/vagrant

RUN mkdir -p /var/run/sshd
CMD /usr/sbin/sshd -D
```

コンテナを立ち上げる
--------------------

`vagrant up`でコンテナを立ち上げます。
裏で`docker build`と`docker run`が走ります。

```console
vagrant up 
```

Dockerfileを更新した場合は、`vagrant reload`で再び`docker build`が走り、新たなイメージでコンテナが起動します。
もちろんコンテナなので、データはコンテナ破棄と同時に消えます。

```console
vagrant reload
```

`vagrant ssh`でログインできて、`sudo`が確認できればOKです。

```console
vagrant ssh hello-docker-provider -- whoami
vagrant ssh hello-docker-provider -- sudo whoami
```

[docker-configuration]: https://www.vagrantup.com/docs/docker/configuration.html
