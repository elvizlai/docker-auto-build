```
docker run --platform linux/amd64 -it  postgres:15-bullseye bash
docker run --platform linux/amd64 -it  postgres:16-bullseye bash
docker run --platform linux/amd64 -it  postgres:17-bullseye bash

# NOT WORKING
# docker run --platform linux/amd64 -it postgres:15-bookworm bash

export CITUS=12.1.5
export POSTGIS=3.5.1+dfsg-1.pgdg110+1
export POSTGRESQL_HLL=2.18
export POSTGRESQL_TOPN=2.7.0
export PGROUTING=3.7.1
export TIMESCALE=2.17.2
export SP_VAULT=0.2.9
export ZOMBODB=3000.2.7
export PARADEDB=0.13.2
export PG_ANALYTICS=0.2.4
export PGVECTOR=0.8.0
export PG_CRON=1.6.4
export PG_IVM=1.9
export PG_MQ=1.5.0
export PG_HINT_PLAN=15_1_5_2
export ORAFCE=4_14_1
export PGSQL_HTTP=1.6.1
export PGAUDIT=1.7.0
export REPMGR=5.5.0
export PG_BACKREST=2.54.1

apt-get update

apt-get install -y --no-install-recommends \
        ca-certificates \
        procps \
        curl \
        build-essential \
        git \
        dpkg-dev \
        gcc \
        libc6-dev \
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

curl -s https://install.citusdata.com/community/deb.sh | bash
apt-get install -y --no-install-recommends \
                postgresql-$PG_MAJOR-citus-12.1=$CITUS.citus-1 \
                postgresql-$PG_MAJOR-postgis-3=$POSTGIS \
                postgresql-$PG_MAJOR-postgis-3-scripts \
                postgresql-$PG_MAJOR-pglogical \
                pg-auto-failover-cli \
                postgresql-$PG_MAJOR-auto-failover

export CARGO_HOME=/tmp/cargo && export RUSTUP_HOME=/tmp/rustup && export PATH=$CARGO_HOME/bin:$PATH \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y


git clone -b v${ZOMBODB} https://github.com/zombodb/zombodb /tmp/zombodb \
    && cd /tmp/zombodb \
    && cargo install -j$(nproc) cargo-pgrx --version $(cat Cargo.toml | grep "pgrx = " | sed 's/pgrx = //g' | sed 's/"//g') \
    && cargo pgrx init --pg${PG_MAJOR}=$(which pg_config) \
    && sudo bash -c 'CARGO_HOME=/tmp/cargo RUSTUP_HOME=/tmp/rustup PATH=$CARGO_HOME/bin:$PATH PGRX_HOME=/var/lib/postgresql/.pgrx cargo pgrx install --release' \


# https://docs.paradedb.com/deploy/self-hosted/extensions
git clone -b v${PARADEDB} https://github.com/paradedb/paradedb /tmp/paradedb
cd /tmp/paradedb
PGRX_VERSION=$(cargo tree --depth 1 -i pgrx -p pg_search | head -n 1 | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
echo "PGRX_VERSION=$PGRX_VERSION"
cargo install --locked cargo-pgrx --version "${PGRX_VERSION}"
cargo pgrx init "--pg${PG_MAJOR}=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config"

cd /tmp/paradedb/pg_search
cargo pgrx install --release --features icu

git clone --branch v${PG_ANALYTICS} https://github.com/paradedb/pg_analytics.git /tmp/pg_analytics
cd /tmp/pg_analytics
cargo pgrx install --release


# repmgr https://github.com/EnterpriseDB/repmgr
wget -O /tmp/repmgr.tar.gz "https://github.com/EnterpriseDB/repmgr/archive/v${REPMGR}.tar.gz" \
&& mkdir -p /tmp/repmgr \
&& tar --extract --file /tmp/repmgr.tar.gz --directory /tmp/repmgr --strip-components 1 \
    && cd /tmp/repmgr \
    && ./configure && make && sudo make install
```