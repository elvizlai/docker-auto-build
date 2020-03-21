FROM sdrzlyz/alpine

RUN set -ex \
    && cd /tmp \
    && wget -O frp.tgz https://github.com/fatedier/frp/releases/download/v$BUILD_VER/frp_$BUILD_VER_linux_amd64.tar.gz \
    && tar zxf frp.tgz -C . --strip-components 1 \
    && mv frpc /usr/local/bin \
    && mv frpc.ini /frpc.ini \
    && rm -rf /tmp/*

CMD exec frpc -c /frpc.ini
