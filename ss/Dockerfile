FROM alpine

ARG SS_VER=3.2.0
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 465
ENV PASSWORD=
ENV METHOD      chacha20
ENV TIMEOUT     300
ENV DNS_ADDRS   8.8.8.8,8.8.4.4
ENV ARGS=

# lib
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev \
      tzdata \
      curl \
      git \
      asciidoc \
      xmlto \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && cd /tmp \
    && curl -sSL $SS_URL | tar xz --strip 1 \
    && autoreconf --install --force \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && apk add --no-cache \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs && git submodule update --init --recursive \
    && ./autogen.sh && ./configure && make && make install \
    && rm -rf /tmp/* && apk del .build-deps && apk add libev

USER root

EXPOSE $SERVER_PORT/tcp $SERVER_PORT/udp

CMD exec ss-server \
      -s $SERVER_ADDR \
      -p $SERVER_PORT \
      -k ${PASSWORD:-$(hostname)} \
      -m $METHOD \
      -t $TIMEOUT \
      --fast-open \
      -d $DNS_ADDRS \
      -u \
      $ARGS