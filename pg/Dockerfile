ARG VERSION=12

FROM postgres:${VERSION}-alpine

ARG CITUS_VERSION=9.5.1 \
    CSTORE_VERSION=1.7.0 \
    POSTGIS_VERSION=3.1.0 \
    PGROUTING_VERSION=3.1.2 \
    TIMESCALE_VERSION=2.0.0

RUN sed 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' -i /etc/apk/repositories \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && apk add --no-cache --virtual .fetch-deps ca-certificates openssl tar \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        file \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
        clang-dev \
        g++ \
        gcc \
        gdal-dev \
        geos-dev \
        llvm10-dev \
        proj-dev \
        protobuf-c-dev \
        curl-dev \
        icu-dev \
        cmake \
        boost-dev \
    && apk add --no-cache --virtual .run-deps \
        json-c \
        geos \
        gdal \
        proj \
        libstdc++ \
        protobuf-c \
# citus https://github.com/citusdata/citus
    && wget -O /tmp/citus.tar.gz "https://github.com/citusdata/citus/archive/v${CITUS_VERSION}.tar.gz" \
        && mkdir -p /tmp/citus \
        && tar --extract --file /tmp/citus.tar.gz --directory /tmp/citus --strip-components 1 \
        && cd /tmp/citus \
        && ./configure \
        && make -j$(nproc) && make install \
# !pg 13 not support now.
# cstore_fdw https://github.com/citusdata/cstore_fdw
    && wget -O /tmp/cstore_fdw.tar.gz "https://github.com/citusdata/cstore_fdw/archive/v${CSTORE_VERSION}.tar.gz" \
         && mkdir -p /tmp/cstore_fdw \
         && tar --extract --file /tmp/cstore_fdw.tar.gz --directory /tmp/cstore_fdw --strip-components 1 \
         && cd /tmp/cstore_fdw \
         && make -j$(nproc) && make install \
# postgis https://github.com/postgis/postgis
    && wget -O /tmp/postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS_VERSION}.tar.gz" \
        && mkdir -p /tmp/postgis \
        && tar --extract --file /tmp/postgis.tar.gz --directory /tmp/postgis --strip-components 1 \
        && cd /tmp/postgis \
        && ./autogen.sh \
        # configure options taken from:
        # https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
        && ./configure \
        # --with-gui \
        && make -j$(nproc) && make install \
# pgrouting https://github.com/pgRouting/pgrouting
    && wget -O /tmp/pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/archive/v${PGROUTING_VERSION}.tar.gz" \
        && mkdir -p /tmp/pgrouting/build \
        && tar --extract --file /tmp/pgrouting.tar.gz --directory /tmp/pgrouting --strip-components 1 \
        && cd /tmp/pgrouting/build \
        && cmake .. \
        && make && make install \
# !pg 13 not support now.
# timescale https://github.com/timescale/timescaledb
    && wget -O /tmp/timescale.tar.gz "https://github.com/timescale/timescaledb/archive/${TIMESCALE_VERSION}.tar.gz" \
        && mkdir -p /tmp/timescale \
        && tar --extract --file /tmp/timescale.tar.gz --directory /tmp/timescale --strip-components 1 \
        && cd /tmp/timescale \
        && ./bootstrap -DREGRESS_CHECKS=OFF -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
        && cd build && make -j$(nproc) && make install \
# clean
    && echo "shared_preload_libraries='citus,cstore_fdw,timescaledb'" >> /usr/local/share/postgresql/postgresql.conf.sample \
    && cd / \
    && rm -rf /tmp/* \
    && apk del .fetch-deps .build-deps

COPY pg_healthcheck /

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
