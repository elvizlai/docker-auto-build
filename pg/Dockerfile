ARG VERSION=13

# Build tools for timescaledb
ARG GO_VERSION=1.14.0
FROM golang:${GO_VERSION}-alpine AS tools

ENV TOOLS_VERSION 0.8.1

# https://github.com/timescale/timescaledb-docker/blob/master/Dockerfile
RUN apk update && apk add --no-cache git \
    && mkdir -p ${GOPATH}/src/github.com/timescale/ \
    && cd ${GOPATH}/src/github.com/timescale/ \
    && git clone https://github.com/timescale/timescaledb-tune.git \
    && git clone https://github.com/timescale/timescaledb-parallel-copy.git \
    # Build timescaledb-tune
    && cd timescaledb-tune/cmd/timescaledb-tune \
    && git fetch && git checkout --quiet $(git describe --abbrev=0) \
    && go get -d -v \
    && go build -o /go/bin/timescaledb-tune \
    # Build timescaledb-parallel-copy
    && cd ${GOPATH}/src/github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy \
    && git fetch && git checkout --quiet $(git describe --abbrev=0) \
    && go get -d -v \
    && go build -o /go/bin/timescaledb-parallel-copy

# postgres
FROM postgres:${VERSION}-alpine

ARG CITUS=10.2.0
ARG POSTGRESQL_HLL=2.16
ARG POSTGRESQL_TOPN=2.4.0
ARG POSTGIS=3.1.4
ARG PG_CRON=1.4.0
ARG PGROUTING=3.2.1
ARG TIMESCALE=2.4.1
ARG GOSU=1.14

ENV LANG zh_CN.utf8

RUN sed 's#https://dl-cdn.alpinelinux.org#https://mirrors.aliyun.com#g' -i /etc/apk/repositories \
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
        llvm \
        clang-dev \
        gdal-dev \
        geos-dev \
        llvm-dev \
        proj-dev \
        protobuf-c-dev \
        pcre-dev \
        curl-dev \
        openssl-dev \
        icu-dev \
        cmake \
        dpkg \
    && apk add --no-cache --virtual .run-deps \
        json-c \
        geos \
        gdal \
        proj \
        pcre \
        libstdc++ \
        protobuf-c \
        zstd \
        zstd-dev \
        lz4 \
        lz4-dev \
# citus https://github.com/citusdata/citus https://github.com/citusdata/docker/blob/master/alpine/Dockerfile
    && wget -O /tmp/citus.tar.gz "https://github.com/citusdata/citus/archive/v${CITUS}.tar.gz" \
        && mkdir -p /tmp/citus \
        && tar --extract --file /tmp/citus.tar.gz --directory /tmp/citus --strip-components 1 \
        && cd /tmp/citus \
        && ./configure --with-security-flags \
        && make -j$(nproc) && make install \
# postgresql-hll https://github.com/citusdata/postgresql-hll
    && wget -O /tmp/postgresql-hll.tar.gz "https://github.com/citusdata/postgresql-hll/archive/v${POSTGRESQL_HLL}.tar.gz" \
        && mkdir -p /tmp/postgresql-hll \
        && tar --extract --file /tmp/postgresql-hll.tar.gz --directory /tmp/postgresql-hll --strip-components 1 \
        && cd /tmp/postgresql-hll \
        && make -j$(nproc) && make install \
# postgresql-topn https://github.com/citusdata/postgresql-topn
    && wget -O /tmp/postgresql-topn.tar.gz "https://github.com/citusdata/postgresql-topn/archive/v${POSTGRESQL_TOPN}.tar.gz" \
        && mkdir -p /tmp/postgresql-topn \
        && tar --extract --file /tmp/postgresql-topn.tar.gz --directory /tmp/postgresql-topn --strip-components 1 \
        && cd /tmp/postgresql-topn \
        && make -j$(nproc) && make install \
# postgis https://github.com/postgis/postgis https://github.com/postgis/docker-postgis
    && wget -O /tmp/postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS}.tar.gz" \
        && mkdir -p /tmp/postgis \
        && tar --extract --file /tmp/postgis.tar.gz --directory /tmp/postgis --strip-components 1 \
        && cd /tmp/postgis \
        && ./autogen.sh \
        # configure options taken from:
        # https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
        && ./configure \
        # --with-gui \
        --with-pcredir="$(pcre-config --prefix)" \
        && make -j$(nproc) && make install \
# pg_cron https://github.com/citusdata/pg_cron https://github.com/citusdata/pg_cron/issues/17
    && wget -O /tmp/pg_cron.tar.gz "https://github.com/citusdata/pg_cron/archive/v${PG_CRON}.tar.gz" \
        && mkdir -p /tmp/pg_cron \
        && tar --extract --file /tmp/pg_cron.tar.gz --directory /tmp/pg_cron --strip-components 1 \
        && cd /tmp/pg_cron \
        && sed -i.bak -e 's/-Werror//g' Makefile \
        && sed -i.bak -e 's/-Wno-implicit-fallthrough//g' Makefile \
        && make && make install \
# pgrouting https://github.com/pgRouting/pgrouting https://github.com/pgRouting/docker-pgrouting
    && wget -O /tmp/pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/archive/v${PGROUTING}.tar.gz" \
        && mkdir -p /tmp/pgrouting/build \
        && tar --extract --file /tmp/pgrouting.tar.gz --directory /tmp/pgrouting --strip-components 1 \
        && cd /tmp/pgrouting/build \
        && cmake .. \
        && make && make install \
# timescale https://github.com/timescale/timescaledb https://github.com/timescale/timescaledb-docker
    && wget -O /tmp/timescale.tar.gz "https://github.com/timescale/timescaledb/archive/${TIMESCALE}.tar.gz" \
        && mkdir -p /tmp/timescale \
        && tar --extract --file /tmp/timescale.tar.gz --directory /tmp/timescale --strip-components 1 \
        && cd /tmp/timescale \
        && ./bootstrap -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
        && cd build && make -j$(nproc) && make install \
# gosu https://github.com/tianon/gosu/blob/master/INSTALL.md
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU/gosu-$dpkgArch" \
    && chmod +x /usr/local/bin/gosu \
# clean
    && cd / \
    && rm -rf /tmp/* \
    && apk del .fetch-deps .build-deps

# multi: using comma as spliter, example: shared_preload_libraries='citus,timescaledb'
RUN echo "shared_preload_libraries='citus,timescaledb,pg_cron'" >> /usr/local/share/postgresql/postgresql.conf.sample

# add scripts to run after initdb
COPY extension/ /docker-entrypoint-initdb.d/

# add tools
COPY --from=tools /go/bin/* /usr/local/bin/

# add health check script
COPY pg_healthcheck wait-for-manager.sh /
RUN chmod +x /wait-for-manager.sh

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh \
    && ln -sf /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh 

# config tuning
# replace last docker_temp_server_stop with sed to change max_connections
RUN sed -i ':a;N;$!ba;s#\(.*\)docker_temp_server_stop#\1docker_temp_server_stop\n                        sed -i "s/max_connections = 100/max_connections = 1000/" /var/lib/postgresql/data/postgresql.conf#' /usr/local/bin/docker-entrypoint.sh

ENV TIMESCALEDB_TELEMETRY off

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
