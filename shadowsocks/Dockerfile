FROM alpine
MAINTAINER sdrzlyz@gmail.com

ENV SS_VERSION=1.1.5

RUN build_pkgs="wget gzip tzdata" && \
    apk add --no-cache --update-cache ${build_pkgs} && \
    wget --no-check-certificate https://github.com/shadowsocks/shadowsocks-go/releases/download/${SS_VERSION}/shadowsocks-server-linux64-${SS_VERSION}.gz && \
    gzip -d -c shadowsocks-server-linux64-${SS_VERSION}.gz  > /ssserver && \
    chmod +x /ssserver && \
    wget --no-check-certificate https://github.com/shadowsocks/shadowsocks-go/releases/download/${SS_VERSION}/shadowsocks-local-linux64-${SS_VERSION}.gz && \
    gzip -d -c shadowsocks-local-linux64-${SS_VERSION}.gz  > /sslocal && \
    chmod +x /sslocal && \
    rm shadowsocks-*.gz && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && \
    rm -rf /tmp/* && \
    apk del ${build_pkgs} && \
    rm -rf /var/cache/apk/*