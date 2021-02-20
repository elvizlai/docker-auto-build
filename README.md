[![Language](https://img.shields.io/badge/Language-Go-blue.svg)](https://golang.org/)
[![Build Status](https://travis-ci.com/elvizlai/docker-auto-build.svg?branch=master)](https://travis-ci.com/elvizlai/docker-auto-build)

#### Apps

- sdrzlyz/alpine
- sdrzlyz/alpine-glibc
- sdrzlyz/centos-sshd
- sdrzlyz/envoy
- sdrzlyz/frpc:0.35.1
- sdrzlyz/go-dev docker protoc revive
- sdrzlyz/ikev2:5.9.1
- sdrzlyz/nginx:1.18.0
- sdrzlyz/pg:12
- sdrzlyz/redis:5.0
- sdrzlyz/tools netcat tcpdump psql mycli
- sdrzlyz/ubuntu

#### [CentOS Docker](https://docs.docker.com/engine/install/centos/)

```
sudo yum install -y yum-utils

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker && sudo systemctl enable docker
```

```
# adding to '/etc/sysctl.conf', then 'sysctl -p'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```
