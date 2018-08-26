FROM alpine

ENV SS 0.0.0.0:465
ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 1465
ENV TIMEOUT     300
ENV ARGS=

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
      gcc autoconf make libtool automake openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers \
      tzdata \
      git \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && cd /tmp \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs && git submodule update --init --recursive \
    && ./autogen.sh && ./configure && make && make install \
    && rm -rf /tmp/* && apk del .build-deps && apk add libev

USER root

CMD exec obfs-server \
      -s $SERVER_ADDR \
      -p $SERVER_PORT \
      -r $SS \
      --fast-open \
      $ARGS