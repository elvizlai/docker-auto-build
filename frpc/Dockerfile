FROM sdrzlyz/alpine

ARG FRP_VER=0.30.0

RUN set -ex \
    && cd /tmp \
    && wget -O frp.tgz https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz \
    && tar zxf frp.tgz -C . --strip-components 1 \
    && mv frpc /usr/local/bin \
    && mv frpc.ini /frpc.ini \
    && rm -rf /tmp/*

CMD exec frpc -c /frpc.ini
