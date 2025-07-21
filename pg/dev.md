### image
```
docker run --platform linux/amd64 -it postgres:15-bullseye bash
docker run --platform linux/amd64 -it postgres:16-bullseye bash
docker run --platform linux/amd64 -it postgres:17-bullseye bash

docker run --platform linux/amd64 -it polardb/polardb_pg_devel:debian11 bash
sudo bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'


# NOT WORKING
# docker run --platform linux/amd64 -it postgres:15-bookworm bash
```

### compile
```
export CITUS=13.1.0
export POSTGIS=3.5.2+dfsg-1.pgdg110+1
export POSTGRESQL_HLL=2.18
export POSTGRESQL_TOPN=2.7.0
export PGROUTING=3.8.0
export TIMESCALE=2.21.0
export SP_VAULT=0.3.1
export PARADEDB=0.17.0
export ZOMBODB=3000.2.8
export PG_ANON=2.3.0
export PGVECTOR=0.8.0
export PG_CRON=1.6.4
export PG_IVM=1.11
export PG_MQ=1.6.1
export ORAFCE=4_14_4
export PGSQL_HTTP=1.6.3
export PG_DUCKDB=0.3.1

export PGAUDIT=1.7.1
export PG_HINT_PLAN=15_1_5_2

export PG_BACKREST=2.55.1


apt-get update && apt-get install -y --no-install-recommends sudo \
    && echo "postgres ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


su postgres -


# postgresql-server-dev: binutils binutils-common binutils-x86-64-linux-gnu clang-16 icu-devtools libasan6 libatomic1 libbinutils libc-dev-bin libc6 libc6-dev libclang-common-16-dev libclang-cpp16 libclang1-16 libcrypt-dev libctf-nobfd0 libctf0 libffi-dev libgc1 libgcc-10-dev libgomp1 libicu-dev libitm1 liblsan0 libmpdec3 libncurses-dev libncurses6 libnsl-dev libobjc-10-dev libobjc4 libpfm4 libpq-dev libpython3-stdlib libpython3.9-minimal libpython3.9-stdlib libquadmath0 libssl-dev libstdc++-10-dev libtirpc-dev libtsan0 libubsan1 libxml2 libxml2-dev libyaml-0-2 libz3-dev linux-libc-dev llvm-16 llvm-16-dev llvm-16-linker-tools llvm-16-runtime llvm-16-tools media-types python3 python3-minimal python3-pkg-resources python3-pygments python3-yaml python3.9 python3.9-minimal

# pgrouting: cmake libboost-graph-dev
# supabase-vault: libsodium-dev libsodium23(运行时)
# age: flex bison
# paradedb: pkg-config libopenblas-dev
# pgsql-http: libcurl4-openssl-dev
# zhparser: bzip2
# pgbackrest: meson python3-setuptools libbz2-dev liblz4-dev libyaml-dev zlib1g-dev libssh2-1-dev libzstd-dev
# pgaudit: libkrb5-dev

sudo apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        postgresql-server-dev-$PG_MAJOR \
        make \
        gcc \
        g++ \
        cmake \
        libboost-graph-dev \
        libsodium-dev \
        flex bison \
        pkg-config libopenblas-dev \
        libcurl4-openssl-dev \
        bzip2 \
        meson python3-setuptools libbz2-dev liblz4-dev libyaml-dev zlib1g-dev libssh2-1-dev libzstd-dev \
        libkrb5-dev \
        libsodium23


curl -s https://install.citusdata.com/community/deb.sh | sudo bash
sudo apt-get install -y --no-install-recommends \
    postgresql-$PG_MAJOR-citus-13.1=$CITUS.citus-1 \
    postgresql-$PG_MAJOR-postgis-3=$POSTGIS \
    postgresql-$PG_MAJOR-postgis-3-scripts \
    postgresql-$PG_MAJOR-pglogical \
    pg-auto-failover-cli \
    postgresql-$PG_MAJOR-auto-failover


wget -O /tmp/hll.tar.gz "https://github.com/citusdata/postgresql-hll/archive/refs/tags/v${POSTGRESQL_HLL}.tar.gz" \
    && mkdir -p /tmp/hll \
    && tar --extract --file /tmp/hll.tar.gz --directory /tmp/hll --strip-components 1 \
    && cd /tmp/hll \
    && make -j$(nproc) && sudo make install


wget -O /tmp/topn.tar.gz "https://github.com/citusdata/postgresql-topn/archive/refs/tags/v${POSTGRESQL_TOPN}.tar.gz" \
    && mkdir -p /tmp/topn \
    && tar --extract --file /tmp/topn.tar.gz --directory /tmp/topn --strip-components 1 \
    && cd /tmp/topn \
    && make -j$(nproc) && sudo make install


wget -O /tmp/pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/archive/v${PGROUTING}.tar.gz" \
    && mkdir -p /tmp/pgrouting/build \
    && tar --extract --file /tmp/pgrouting.tar.gz --directory /tmp/pgrouting --strip-components 1 \
    && cd /tmp/pgrouting/build \
    && cmake .. && make -j$(nproc) && sudo make install


git clone -b ${TIMESCALE} https://github.com/timescale/timescaledb /tmp/timescale \
    && cd /tmp/timescale \
    && ./bootstrap -DCMAKE_BUILD_TYPE=RelWithDebInfo -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker" \
    && cd build && make -j$(nproc) && sudo make install


git clone -b v${SP_VAULT} https://github.com/supabase/vault /tmp/vault \
    && cd /tmp/vault \
    && make -j$(nproc) && sudo make install


git clone -b PG${PG_MAJOR} https://github.com/apache/age /tmp/age \
    && cd /tmp/age \
    && make -j$(nproc) && sudo make install


export RUSTUP_HOME=/tmp/rustup && export CARGO_HOME=/tmp/cargo && export PATH=$CARGO_HOME/bin:$PATH \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y


# Yes, running ldconfig twice
wget -O /tmp/icu4c.tgz https://github.com/unicode-org/icu/releases/download/release-76-1/icu4c-76_1-src.tgz \
    && mkdir -p /tmp/icu \
    && tar --extract --file /tmp/icu4c.tgz --directory /tmp/icu --strip-components 1 \
    && cd /tmp/icu/source/ \
    && ./runConfigureICU Linux --prefix=/usr/local && make "-j$(nproc)" && sudo make install \
    && sudo ldconfig && sudo ldconfig \
    && git clone -b v${PARADEDB} https://github.com/paradedb/paradedb /tmp/paradedb \
    && cd /tmp/paradedb \
    && PGRX_VERSION=$(cargo tree --depth 1 -i pgrx -p pg_search | head -n 1 | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/') \
    && echo "PGRX_VERSION=$PGRX_VERSION" \
    && cargo install --locked cargo-pgrx --version "${PGRX_VERSION}" \
    && cargo pgrx init "--pg${PG_MAJOR}=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
    && cd /tmp/paradedb/pg_search \
    && sudo bash -c 'RUSTUP_HOME=/tmp/rustup CARGO_HOME=/tmp/cargo PATH=$CARGO_HOME/bin:$PATH PGRX_HOME=/var/lib/postgresql/.pgrx PARADEDB_TELEMETRY=false cargo pgrx install --features icu --release'


git clone -b v${ZOMBODB} https://github.com/zombodb/zombodb /tmp/zombodb \
    && cd /tmp/zombodb \
    && cargo install -j$(nproc) cargo-pgrx --version $PGRX_VERSION --locked \
    && cargo pgrx init --pg${PG_MAJOR}=$(which pg_config) \
    && sudo bash -c 'RUSTUP_HOME=/tmp/rustup CARGO_HOME=/tmp/cargo PATH=$CARGO_HOME/bin:$PATH PGRX_HOME=/var/lib/postgresql/.pgrx cargo pgrx install --release'


git clone --branch ${PG_ANON} https://gitlab.com/dalibo/postgresql_anonymizer.git /tmp/pg_anonymizer \
    && cd /tmp/pg_anonymizer \
    && cargo install -j$(nproc) cargo-pgrx --version $(cat Cargo.toml | grep "pgrx = " | sed 's/pgrx = //g' | sed 's/"//g') \
    && PGRX_HOME=/var/lib/postgresql/.pgrx cargo pgrx init "--pg${PG_MAJOR}=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
    && PGRX_HOME=/var/lib/postgresql/.pgrx make extension PG_CONFIG=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config PGVER=pg${PG_MAJOR} \
    && sudo bash -c 'RUSTUP_HOME=/tmp/rustup CARGO_HOME=/tmp/cargo PATH=$CARGO_HOME/bin:$PATH PGRX_HOME=/var/lib/postgresql/.pgrx make install PG_CONFIG=/usr/lib/postgresql/15/bin/pg_config PGVER=pg15'


git clone -b v${PGVECTOR} https://github.com/pgvector/pgvector /tmp/pgvector \
    && cd /tmp/pgvector \
    && make -j$(nproc) && sudo make install


git clone https://github.com/jirutka/smlar /tmp/smlar \
    && cd /tmp/smlar \
    && sudo make install USE_PGXS=1 \


wget -O /tmp/pg_cron.tar.gz "https://github.com/citusdata/pg_cron/archive/v${PG_CRON}.tar.gz" \
    && mkdir -p /tmp/pg_cron \
    && tar -zxf /tmp/pg_cron.tar.gz -C /tmp/pg_cron --strip-components 1 \
    && cd /tmp/pg_cron \
    && make -j$(nproc) && sudo make install


wget -O /tmp/pg_ivm.tar.gz "https://github.com/sraoss/pg_ivm/archive/v${PG_IVM}.tar.gz" \
    && mkdir -p /tmp/pg_ivm \
    && tar -zxf /tmp/pg_ivm.tar.gz -C /tmp/pg_ivm --strip-components 1 \
    && cd /tmp/pg_ivm \
    && make -j$(nproc) && sudo make install


git clone -b v${PG_MQ} https://github.com/tembo-io/pgmq /tmp/pgmq \
    && cd /tmp/pgmq/pgmq-extension \
    && make -j$(nproc) && sudo make install


wget -O /tmp/orafce.tar.gz "https://github.com/orafce/orafce/archive/VERSION_${ORAFCE}.tar.gz" \
    && mkdir -p /tmp/orafce \
    && tar --extract --file /tmp/orafce.tar.gz --directory /tmp/orafce --strip-components 1 \
    && cd /tmp/orafce \
    && make -j$(nproc) && sudo make install


wget -O /tmp/pgsql-http.tar.gz "https://github.com/pramsey/pgsql-http/archive/v${PGSQL_HTTP}.tar.gz" \
    && mkdir -p /tmp/pgsql-http \
    && tar --extract --file /tmp/pgsql-http.tar.gz --directory /tmp/pgsql-http --strip-components 1 \
    && cd /tmp/pgsql-http \
    && make -j$(nproc) && sudo make install


git clone -b v2.3 https://github.com/amutu/zhparser /tmp/zhparser \
    && mkdir -p /tmp/zhparser/scws \
    && cd /tmp/zhparser/scws \
    && wget -q -O - http://www.xunsearch.com/scws/down/scws-1.2.3.tar.bz2 | tar xjf - --strip-components 1 \
    && ./configure && sudo make install \
    && cd .. && make -j$(nproc) && sudo make install


git clone -b v${PG_DUCKDB} https://github.com/duckdb/pg_duckdb /tmp/pg_duckdb \
    && cd /tmp/pg_duckdb \
    && git submodule update --init --recursive \
    && make -j$(nproc) && sudo make install DUCKDB_BUILD=ReleaseStatic


wget -O /tmp/pgaudit.tar.gz "https://github.com/pgaudit/pgaudit/archive/${PGAUDIT}.tar.gz" \
    && mkdir -p /tmp/pgaudit \
    && tar --extract --file /tmp/pgaudit.tar.gz --directory /tmp/pgaudit --strip-components 1 \
    && cd /tmp/pgaudit \
    && sudo make install USE_PGXS=1


wget -O /tmp/pg_hint_plan.tar.gz "https://github.com/ossc-db/pg_hint_plan/archive/REL${PG_HINT_PLAN}.tar.gz" \
    && mkdir -p /tmp/pg_hint_plan \
    && tar --extract --file /tmp/pg_hint_plan.tar.gz --directory /tmp/pg_hint_plan --strip-components 1 \
    && cd /tmp/pg_hint_plan \
    && make -j$(nproc) && sudo make install


git clone https://github.com/eulerto/wal2json /tmp/wal2json \
    && cd /tmp/wal2json \
    && make -j$(nproc) && sudo make install


git clone https://github.com/michaelpq/pg_plugins /tmp/pg_plugins \
    && cd /tmp/pg_plugins/decoder_raw \
    && make -j$(nproc) && sudo make install


wget -O /tmp/pgbackrest.tar.gz https://github.com/pgbackrest/pgbackrest/archive/release/${PG_BACKREST}.tar.gz \
    && mkdir -p /tmp/pgbackrest \
    && tar --extract --file /tmp/pgbackrest.tar.gz --directory /tmp/pgbackrest --strip-components 1 \
    && meson setup /tmp/pgbackrest /tmp/pgbackrest-release \
    && ninja -C /tmp/pgbackrest-release \
    && sudo mv /tmp/pgbackrest-release/src/pgbackrest /usr/bin \
    && sudo mkdir -p /var/log/pgbackrest /var/lib/pgbackrest /etc/pgbackrest \
    && sudo chown -R postgres:postgres /var/log/pgbackrest /var/lib/pgbackrest /etc/pgbackrest


sudo bash -c 'echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen' && sudo locale-gen


sudo apt-get autoremove --purge -y --auto-remove --allow-remove-essential \
        ca-certificates \
        curl \
        wget \
        git \
        postgresql-server-dev-$PG_MAJOR \
        make \
        gcc \
        g++ \
        cmake \
        libboost-graph-dev \
        libsodium-dev \
        flex bison \
        pkg-config libopenblas-dev \
        libcurl4-openssl-dev \
        bzip2 \
        meson python3-setuptools libbz2-dev liblz4-dev libyaml-dev zlib1g-dev libssh2-1-dev libzstd-dev \
        libkrb5-dev




# repmgr https://github.com/EnterpriseDB/repmgr

cp /usr/include/postgresql/15/server/pg_config.h /usr/include/postgresql/

wget -O /tmp/repmgr.tar.gz "https://github.com/EnterpriseDB/repmgr/archive/v${REPMGR}.tar.gz" \
&& mkdir -p /tmp/repmgr \
&& tar --extract --file /tmp/repmgr.tar.gz --directory /tmp/repmgr --strip-components 1 \
    && cd /tmp/repmgr \
    && ./configure && make -j$(nproc) && sudo make install
```
