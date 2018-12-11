FROM sdrzlyz/alpine

ARG SS_VER=3.2.3
ARG SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_ADDR_IPV6 ::0
ENV SERVER_PORT 465
ENV PASSWORD=
ENV METHOD      aes-256-cfb
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
      curl \
    && cd /tmp \
    && curl -sSL $SS_URL | tar xz --strip 1 \
    && autoreconf --install --force \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && apk del .build-deps && rm -rf /tmp/* \
    && apk add --no-cache \
      rng-tools \
      libev \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u)

USER root

EXPOSE $SERVER_PORT/tcp $SERVER_PORT/udp

CMD exec ss-server \
      -s $SERVER_ADDR \
      -s $SERVER_ADDR_IPV6 \
      -p $SERVER_PORT \
      -k ${PASSWORD:-$(hostname)} \
      -m $METHOD \
      -t $TIMEOUT \
      --fast-open \
      -d $DNS_ADDRS \
      -u \
      $ARGS
