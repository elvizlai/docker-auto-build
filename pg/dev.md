```
docker run -it postgres:15-bullseye bash

export CITUS=12.1.5
export POSTGRESQL_HLL=2.18
export POSTGRESQL_TOPN=2.7.0
export POSTGIS=3.5.0+dfsg-1.pgdg110+1
export PGROUTING=3.6.3
export TIMESCALE=2.17.2
export SP_VAULT=0.2.9
export ZOMBODB=3000.2.7
export PGVECTOR=0.8.0
export PG_MQ=1.4.5
export PG_HINT_PLAN=15_1_5_2
export PG_CRON=1.6.4
export PG_IVM=1.9
export ORAFCE=4_14_0
export PGSQL_HTTP=1.6.1
export PGAUDIT=1.7.0
export REPMGR=5.5.0
export PG_BACKREST=2.54.0

apt-get update

apt-get install -y --no-install-recommends \
        ca-certificates \
        procps \
        curl \
        build-essential \
        git \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        wget \
        pkg-config \
        postgresql-server-dev-$PG_MAJOR \
        libboost-graph-dev \
        libkrb5-dev \
        bison flex zlib1g-dev libreadline-dev \
        zlib1g libssl-dev \
        libcurl4-openssl-dev \
        liblz4-dev libzstd-dev libedit-dev libpam0g-dev libselinux1-dev libxml2-dev libxslt1-dev libjson-c-dev \
        libyaml-dev libbz2-dev

# repmgr https://github.com/EnterpriseDB/repmgr
wget -O /tmp/repmgr.tar.gz "https://github.com/EnterpriseDB/repmgr/archive/v${REPMGR}.tar.gz" \
&& mkdir -p /tmp/repmgr \
&& tar --extract --file /tmp/repmgr.tar.gz --directory /tmp/repmgr --strip-components 1 \
    && cd /tmp/repmgr \
    && ./configure && make && sudo make install
```