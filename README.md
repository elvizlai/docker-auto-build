#### Images

- sdrzlyz/alpine
- sdrzlyz/alpine-glibc
- sdrzlyz/centos-sshd
- sdrzlyz/envoy:1.18.3
- sdrzlyz/ffmpeg
- sdrzlyz/go-dev
- sdrzlyz/ikev2:5.9.3
- sdrzlyz/nginx:1.20.1
- sdrzlyz/pg:13
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
