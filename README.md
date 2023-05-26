#### Images

- sdrzlyz/alpine
- sdrzlyz/alpine-glibc
- sdrzlyz/centos-sshd
- sdrzlyz/envoy:1.26.1
- sdrzlyz/ffmpeg
- sdrzlyz/go-dev
- sdrzlyz/ikev2:5.9.9
- sdrzlyz/ml
- sdrzlyz/nginx:1.24.0
- sdrzlyz/pg:13
- sdrzlyz/prest:1.3.1
- sdrzlyz/redis:7.0
- sdrzlyz/strapi:4.3.4
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
