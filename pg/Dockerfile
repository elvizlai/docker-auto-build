ARG VERSION=13

FROM postgres:${VERSION}-alpine

ARG CITUS_VERSION=10.0.3
ARG POSTGIS_VERSION=3.1.1
ARG PGROUTING_VERSION=3.1.3
ARG TIMESCALE_VERSION=2.1.0

RUN sed 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' -i /etc/apk/repositories \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && apk add --no-cache --virtual .fetch-deps ca-certificates openssl tar \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        boost-dev \
        autoconf \
        automake \
        file \
        json-c-dev \
        libtool \
        libxml2-dev \
        perl \
        clang-dev \
        gdal-dev \
        geos-dev \
        llvm10-dev \
        proj-dev \
        protobuf-c-dev \
        curl-dev \
        openssl-dev \
        icu-dev \
        cmake \
    && apk add --no-cache --virtual .run-deps \
        json-c \
        geos \
        gdal \
        proj \
        libstdc++ \
        protobuf-c \
        zstd \
        zstd-dev \        
        lz4 \
        lz4-dev \
# citus https://github.com/citusdata/citus https://github.com/citusdata/docker/blob/master/Dockerfile-alpine
    && wget -O /tmp/citus.tar.gz "https://github.com/citusdata/citus/archive/v${CITUS_VERSION}.tar.gz" \
        && mkdir -p /tmp/citus \
        && tar --extract --file /tmp/citus.tar.gz --directory /tmp/citus --strip-components 1 \
        && cd /tmp/citus \
        && ./configure \
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
# timescale https://github.com/timescale/timescaledb
    && wget -O /tmp/timescale.tar.gz "https://github.com/timescale/timescaledb/archive/${TIMESCALE_VERSION}.tar.gz" \
        && mkdir -p /tmp/timescale \
        && tar --extract --file /tmp/timescale.tar.gz --directory /tmp/timescale --strip-components 1 \
        && cd /tmp/timescale \
        && ./bootstrap -DREGRESS_CHECKS=OFF -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
        && cd build && make -j$(nproc) && make install \
# clean
    && cd / \
    && rm -rf /tmp/* \
    && apk del .fetch-deps .build-deps

RUN echo "shared_preload_libraries='citus,timescaledb'" >> /usr/local/share/postgresql/postgresql.conf.sample

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

COPY pg_healthcheck /

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
