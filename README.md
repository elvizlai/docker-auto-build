#### Images

- sdrzlyz/alpine
- sdrzlyz/alpine-glibc
- sdrzlyz/centos-sshd
- sdrzlyz/envoy:1.23.0
- sdrzlyz/ffmpeg
- sdrzlyz/go-dev
- sdrzlyz/ikev2:5.9.6
- sdrzlyz/m7s:4.0.1
- sdrzlyz/nginx:1.22.0
- sdrzlyz/pg:13
- sdrzlyz/redis:7.0
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
