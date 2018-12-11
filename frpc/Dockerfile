FROM alpine

ARG FRP_VER=0.22.0

RUN set -ex && \
    wget -O /tmp/frp.tgz https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz && \
    cd /tmp && tar zxf frp.tgz -C /tmp --strip-components 1 && \
    mv /tmp/frpc /usr/local/bin && \
    mv /tmp/frpc.ini /frpc.ini && \
    rm -f /tmp/*

CMD exec frpc -c /frpc.ini
