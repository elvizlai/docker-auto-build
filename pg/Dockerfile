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
FROM postgres:${VERSION}

ARG CITUS=10.2.1
ARG POSTGRESQL_HLL=2.16
ARG POSTGRESQL_TOPN=2.4.0
ARG POSTGIS=3.1.4+dfsg-1.pgdg110+1
ARG PG_CRON=1.4.1
ARG PGROUTING=3.2.1
ARG TIMESCALE=2.4.1
ARG PGAUDIT=1.5.0
ARG GOSU=1.14

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       procps \
       \
       curl \
       build-essential \
       libssl-dev \
       dpkg-dev \
       gcc \
       libc-dev \
       make \
       cmake \
       wget \
       postgresql-server-dev-13 \
       libkrb5-dev \
# citus hll topn
# citus https://github.com/citusdata/citus https://github.com/citusdata/docker/blob/master/Dockerfile
    && curl -s https://install.citusdata.com/community/deb.sh | bash \       
    && apt-get install -y postgresql-$PG_MAJOR-citus-10.2=$CITUS.citus-1 \
                          postgresql-$PG_MAJOR-hll=$POSTGRESQL_HLL.citus-1 \
                          postgresql-$PG_MAJOR-topn=$POSTGRESQL_TOPN \
# postgis https://github.com/postgis/postgis https://github.com/postgis/docker-postgis/blob/master/13-3.1/Dockerfile
                          postgresql-$PG_MAJOR-postgis-3=$POSTGIS \
                          postgresql-$PG_MAJOR-postgis-3-scripts \
# pgcron https://github.com/citusdata/pg_cron
                          postgresql-13-cron \
# timescale https://github.com/timescale/timescaledb https://github.com/timescale/timescaledb-docker
    && wget -O /tmp/timescale.tar.gz "https://github.com/timescale/timescaledb/archive/${TIMESCALE}.tar.gz" \
        && mkdir -p /tmp/timescale \
        && tar --extract --file /tmp/timescale.tar.gz --directory /tmp/timescale --strip-components 1 \
        && cd /tmp/timescale \
        && ./bootstrap -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
        && cd build && make -j$(nproc) && make install \
# pgaudit https://github.com/pgaudit/pgaudit
    && wget -O /tmp/pgaudit.tar.gz "https://github.com/pgaudit/pgaudit/archive/${PGAUDIT}.tar.gz" \
        && mkdir -p /tmp/pgaudit \
        && tar --extract --file /tmp/pgaudit.tar.gz --directory /tmp/pgaudit --strip-components 1 \
        && cd /tmp/pgaudit \
        && make install USE_PGXS=1 \
# gosu https://github.com/tianon/gosu/blob/master/INSTALL.md
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
        && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU/gosu-$dpkgArch" \
        && chmod +x /usr/local/bin/gosu \
# locale
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
# clean
    && apt-get autoremove --purge -y \
        curl \
        build-essential \
        libssl-dev \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        wget \
        postgresql-server-dev-13 \
        libkrb5-dev \
    && apt-get clean -y \
    && rm -rf \
      "${HOME}/.cache" \
        /var/lib/apt/lists/* \
        /tmp/*               \
        /var/tmp/*

# multi: using comma as spliter, example: shared_preload_libraries='citus,timescaledb'
RUN echo "shared_preload_libraries='citus,timescaledb,pg_cron,pgaudit'" >> /usr/share/postgresql/postgresql.conf.sample

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
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh \
    && ln -sf /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh 

# config tuning
# replace last docker_temp_server_stop with sed to change max_connections
RUN sed -i ':a;N;$!ba;s#\(.*\)docker_temp_server_stop#\1docker_temp_server_stop\n                        sed -i "s/max_connections = 100/max_connections = 1000/" /var/lib/postgresql/data/postgresql.conf#' /usr/local/bin/docker-entrypoint.sh

ENV TIMESCALEDB_TELEMETRY off

HEALTHCHECK --interval=4s --start-period=6s CMD ./pg_healthcheck
