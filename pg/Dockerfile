ARG VERSION=13

# Build tools for timescaledb
ARG GO_VERSION=1.14.0
FROM golang:${GO_VERSION}-alpine AS tools

ENV TOOLS_VERSION 0.8.1

# https://github.com/timescale/timescaledb-docker/blob/master/Dockerfile
RUN apk update && apk add --no-cache git \
    && go get github.com/timescale/timescaledb-tune/cmd/timescaledb-tune \
    && go get github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy \
    && go get github.com/timescale/timescaledb-backup/cmd/ts-dump \
    && go get github.com/timescale/timescaledb-backup/cmd/ts-restore \
    && go build -o /go/bin/timescaledb-tune -v github.com/timescale/timescaledb-tune/cmd/timescaledb-tune \
    && go build -o /go/bin/timescaledb-parallel-copy -v github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy \
    && go build -o /go/bin/ts-dump -v github.com/timescale/timescaledb-backup/cmd/ts-dump \
    && go build -o /go/bin/ts-restore -v github.com/timescale/timescaledb-backup/cmd/ts-restore

# postgres
FROM postgres:${VERSION}

ARG CITUS=11.0.6
ARG POSTGRESQL_HLL=2.16
ARG POSTGRESQL_TOPN=2.4.0
ARG POSTGIS=3.2.2+dfsg-1.pgdg110+1
ARG PGROUTING=3.3.1
ARG TIMESCALE=2.7.2
ARG ZOMBODB=3000.1.3
ARG PG_CRON=1.4.2
ARG PG_IVM=1.2
ARG ORAFCE=3_24_4
ARG PGSQL_HTTP=1.5.0
ARG PGAUDIT=1.5.2
ARG REPMGR=5.3.2
ARG GOSU=1.14

# set timezone
ENV TZ PRC

COPY _curl.sh /usr/local/bin/

RUN _curl.sh https://packages.groonga.org/debian/groonga-apt-source-latest-bullseye.deb > /tmp/groonga.deb \
    && apt install -y /tmp/groonga.deb \
    && apt-get update && apt-get install -y --no-install-recommends sudo \
    && echo "postgres ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER postgres

RUN sudo apt-get install -y --no-install-recommends \
        ca-certificates \
        procps \
        \
        curl \
        build-essential \
        libssl-dev \
        git \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        wget \
        postgresql-server-dev-$PG_MAJOR \
        libkrb5-dev \
        libboost-graph-dev \
        \
        bison flex zlib1g zlib1g-dev \
        pkg-config libreadline-dev \
        \
        libcurl4-openssl-dev \
# citus https://github.com/citusdata/citus https://github.com/citusdata/docker/blob/master/Dockerfile
# hll https://github.com/citusdata/postgresql-hll https://github.com/citusdata/postgresql-hll/tags
# topn https://github.com/citusdata/postgresql-topn https://github.com/citusdata/postgresql-topn/tags
    && curl -s https://install.citusdata.com/community/deb.sh | sudo bash \
    && sudo apt-get install -y --no-install-recommends \
                        postgresql-$PG_MAJOR-citus-11.0=$CITUS.citus-1 \
                        postgresql-$PG_MAJOR-hll=$POSTGRESQL_HLL.citus-1 \
                        postgresql-$PG_MAJOR-topn=$POSTGRESQL_TOPN \
# pglogical https://github.com/2ndQuadrant/pglogical
                        postgresql-$PG_MAJOR-pglogical \
# postgis https://github.com/postgis/postgis/tags https://github.com/postgis/docker-postgis/blob/master/13-3.2/Dockerfile
                        postgresql-$PG_MAJOR-postgis-3=$POSTGIS \
                        postgresql-$PG_MAJOR-postgis-3-scripts \
# pgroonga https://github.com/pgroonga/pgroonga
                        postgresql-$PG_MAJOR-pgdg-pgroonga \
# pgrouting https://github.com/pgRouting/pgrouting https://github.com/pgRouting/docker-pgrouting
    && wget -O /tmp/pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/archive/v${PGROUTING}.tar.gz" \
        && mkdir -p /tmp/pgrouting/build \
        && tar --extract --file /tmp/pgrouting.tar.gz --directory /tmp/pgrouting --strip-components 1 \
        && cd /tmp/pgrouting/build \
        && cmake .. \
        && make && sudo make install \
# timescale https://github.com/timescale/timescaledb https://github.com/timescale/timescaledb-docker
    && git clone -b ${TIMESCALE} https://github.com/timescale/timescaledb /tmp/timescale \
        && cd /tmp/timescale \
        && ./bootstrap -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
        && cd build && make -j$(nproc) && sudo make install \
# zombodb https://github.com/zombodb/zombodb
    && export CARGO_HOME=/tmp/cargo && export RUSTUP_HOME=/tmp/rustup && export PATH=$CARGO_HOME/bin:$PATH \
        && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y \
        && git clone -b v${ZOMBODB} https://github.com/zombodb/zombodb /tmp/zombodb \
        && cd /tmp/zombodb \
        && cargo install cargo-pgx --version `cat Cargo.toml | grep "pgx = " | sed 's/pgx = //g'` \
        && cargo pgx init --pg13=`which pg_config` \
        && sudo bash -c 'CARGO_HOME=/tmp/cargo RUSTUP_HOME=/tmp/rustup PATH=$CARGO_HOME/bin:$PATH PGX_HOME=/var/lib/postgresql/.pgx cargo pgx install --release' \
        && sudo rm -rf /var/lib/postgresql/.pgx || true \
# pgcron https://github.com/citusdata/pg_cron
    && wget -O /tmp/pg_cron.tar.gz "https://github.com/citusdata/pg_cron/archive/v${PG_CRON}.tar.gz" \
        && mkdir -p /tmp/pg_cron \
        && tar -zxf /tmp/pg_cron.tar.gz -C /tmp/pg_cron --strip-components 1 \
        && cd /tmp/pg_cron \
        && make && sudo make install \
# pg_ivm https://github.com/sraoss/pg_ivm
    && wget -O /tmp/pg_ivm.tar.gz "https://github.com/sraoss/pg_ivm/archive/v${PG_IVM}.tar.gz" \
        && mkdir -p /tmp/pg_ivm \
        && tar -zxf /tmp/pg_ivm.tar.gz -C /tmp/pg_ivm --strip-components 1 \
        && cd /tmp/pg_ivm \
        && make && sudo make install \
# orafce https://github.com/orafce/orafce
    && wget -O /tmp/orafce.tar.gz "https://github.com/orafce/orafce/archive/VERSION_${ORAFCE}.tar.gz" \
        && mkdir -p /tmp/orafce \
        && tar --extract --file /tmp/orafce.tar.gz --directory /tmp/orafce --strip-components 1 \
        && cd /tmp/orafce \
        && make && sudo make install \
# pgsql-http https://github.com/pramsey/pgsql-http
    && wget -O /tmp/pgsql-http.tar.gz "https://github.com/pramsey/pgsql-http/archive/v${PGSQL_HTTP}.tar.gz" \
        && mkdir -p /tmp/pgsql-http \
        && tar --extract --file /tmp/pgsql-http.tar.gz --directory /tmp/pgsql-http --strip-components 1 \
        && cd /tmp/pgsql-http \
        && make && sudo make install \
# pgaudit https://github.com/pgaudit/pgaudit/tags
    && wget -O /tmp/pgaudit.tar.gz "https://github.com/pgaudit/pgaudit/archive/${PGAUDIT}.tar.gz" \
        && mkdir -p /tmp/pgaudit \
        && tar --extract --file /tmp/pgaudit.tar.gz --directory /tmp/pgaudit --strip-components 1 \
        && cd /tmp/pgaudit \
        && sudo make install USE_PGXS=1 \
# pg_jieba https://github.com/jaiminpan/pg_jieba
    && git clone https://github.com/jaiminpan/pg_jieba /tmp/pg_jieba \
        && cd /tmp/pg_jieba \
        && git submodule update --init --recursive \
        && mkdir build && cd build \
        && cmake -DCMAKE_PREFIX_PATH=/usr/share/postgresql/$PG_MAJOR -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/$PG_MAJOR/server .. \
        && make && sudo make install \
# XLogMiner https://gitee.com/movead/XLogMiner
    && git clone https://gitee.com/movead/XLogMiner /tmp/XLogMiner \
        && cd /tmp/XLogMiner/walminer \
        && USE_PGXS=1 MAJORVERSION=$PG_MAJOR make \
        && sudo USE_PGXS=1 MAJORVERSION=$PG_MAJOR make install \
# wal2json https://github.com/eulerto/wal2json
    && git clone https://github.com/eulerto/wal2json /tmp/wal2json \
        && cd /tmp/wal2json \
        && make && sudo make install \
# decoder_raw https://github.com/michaelpq/pg_plugins
    && git clone https://github.com/michaelpq/pg_plugins /tmp/pg_plugins \
        && cd /tmp/pg_plugins/decoder_raw \
        && make && sudo make install \
# repmgr https://github.com/EnterpriseDB/repmgr
    && wget -O /tmp/repmgr.tar.gz "https://repmgr.org/download/repmgr-${REPMGR}.tar.gz" \
    && mkdir -p /tmp/repmgr \
    && tar --extract --file /tmp/repmgr.tar.gz --directory /tmp/repmgr --strip-components 1 \
        && cd /tmp/repmgr \
        && ./configure && make && sudo make install \
# gosu https://github.com/tianon/gosu/blob/master/INSTALL.md
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
        && sudo wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU/gosu-$dpkgArch" \
        && sudo chmod +x /usr/local/bin/gosu \
# locale
    && sudo bash -c 'echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen' && sudo locale-gen \
# clean
    && sudo apt-get autoremove --purge -y --allow-remove-essential \
        curl \
        build-essential \
        libssl-dev \
        git \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        wget \
        postgresql-server-dev-$PG_MAJOR \
        libkrb5-dev \
        libboost-graph-dev \
        bison flex zlib1g-dev \
        pkg-config libreadline-dev \
        libcurl4-openssl-dev \
    && sudo apt-get clean -y \
    && sudo rm -rf \
        "${HOME}/.cache" \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

USER root

# multi: using comma as spliter, example: shared_preload_libraries='citus,timescaledb'
RUN echo "shared_preload_libraries='citus,pglogical,timescaledb,pg_cron,pgaudit'" >> /usr/share/postgresql/postgresql.conf.sample

# select name,setting from pg_settings where name like 'pgaudit%';
# all but except misc
#pgaudit.log = 'all, -misc'
#pgaudit.log_client = on
#pgaudit.log_parameter = on
#pgaudit.log_relation = on
#pgaudit.log_statement_once = on

# add scripts to run after initdb
COPY extension/ /docker-entrypoint-initdb.d/

# add tools
COPY --from=tools /go/bin/* /usr/local/bin/

# add health check script
COPY pg_healthcheck wait-for-manager.sh /
RUN chmod +x /wait-for-manager.sh

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

# config tuning
# replace last docker_temp_server_stop with sed to change max_connections
RUN sed -i ':a;N;$!ba;s#\(.*\)docker_temp_server_stop#\1docker_temp_server_stop\n                        sed -i "s/max_connections = 100/max_connections = 1000/" /var/lib/postgresql/data/postgresql.conf#' /usr/local/bin/docker-entrypoint.sh

ENV TIMESCALEDB_TELEMETRY off

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
