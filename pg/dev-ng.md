
### image
```
docker run --platform linux/amd64 -it postgres:15-bookworm bash
```


### compile
```
apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates curl \
    && echo "postgres ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

su postgres -

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg
curl -fsSL https://repo.pigsty.io/key | sudo gpg --dearmor -o /etc/apt/keyrings/pigsty.gpg

. /etc/os-release

sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null <<EOF
deb [signed-by=/etc/apt/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main
EOF

sudo tee /etc/apt/sources.list.d/pigsty-io.list > /dev/null <<EOF
deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.io/apt/infra generic main
deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.io/apt/pgsql/${VERSION_CODENAME} ${VERSION_CODENAME} main
EOF


# 安装 pig
curl -fsSL https://repo.pigsty.io/pig | sudo bash

# 刷新缓存
pig repo update

sudo apt-get install -y --no-install-recommends \
    postgresql-server-dev-$PG_MAJOR git gcc pkg-config libssl-dev

# rust
export RUSTUP_HOME=/tmp/rustup && export CARGO_HOME=/tmp/cargo && export PATH=$CARGO_HOME/bin:$PATH \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# zombodb
git clone -b v3000.2.8 https://github.com/zombodb/zombodb /tmp/zombodb \
    && cd /tmp/zombodb \
    && cargo install -j$(nproc) cargo-pgrx --version 0.13.0 --locked \
    && cargo pgrx init --pg${PG_MAJOR}=$(which pg_config) \
    && sudo bash -c 'RUSTUP_HOME=/tmp/rustup CARGO_HOME=/tmp/cargo PATH=$CARGO_HOME/bin:$PATH PGRX_HOME=/var/lib/postgresql/.pgrx cargo pgrx install --release'

sudo apt-get autoremove -y --purge \
    curl \
    postgresql-server-dev-$PG_MAJOR git gcc pkg-config libssl-dev
```

