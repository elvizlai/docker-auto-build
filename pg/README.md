# PostgreSQL

基于官方 `postgres:<version>-bookworm` 镜像，通过 [Pigsty](https://pgext.cloud/) 预装常用扩展。

## Quick Start

```bash
docker run -d \
    --restart always \
    --name pg \
    -v /data/pg:/var/lib/postgresql/data \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    -p 5432:5432 \
    sdrzlyz/pg:18
```

### 扩展自动更新

升级同大版本镜像时，入口脚本会在开放 5432 端口前自动更新各库中已安装且版本落后的扩展（未安装的库不会改动）。

- `AUTO_UPDATE_EXTENSIONS=all`：默认值，更新全部已安装且过期的扩展
- `AUTO_UPDATE_EXTENSIONS=timescaledb,vector`：只更新指定扩展
- `AUTO_UPDATE_EXTENSIONS=off`（或 `false` / 空值）：关闭自动更新

手动触发：

```bash
docker exec pg update-extensions.sh
```

## Extensions

连接 `psql -U postgres` 后按需启用：

```sql
CREATE EXTENSION citus;

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder; -- PG 16+

CREATE EXTENSION pgrouting;
CREATE EXTENSION timescaledb;
CREATE EXTENSION timescaledb_toolkit;
CREATE EXTENSION pg_duckdb;
CREATE EXTENSION pg_mooncake;
CREATE EXTENSION supabase_vault;
CREATE EXTENSION age;
CREATE EXTENSION anon;
CREATE EXTENSION vector;
CREATE EXTENSION vchord;
CREATE EXTENSION vchord_bm25;
CREATE EXTENSION pg_cron;
CREATE EXTENSION pg_ivm;
CREATE EXTENSION pgmq;
CREATE EXTENSION orafce;
CREATE EXTENSION http;
CREATE EXTENSION zhparser;
CREATE EXTENSION pg_repack;
CREATE EXTENSION zombodb; -- PG 15

-- 以下扩展需先加入 shared_preload_libraries 后重启
CREATE EXTENSION pglogical;
CREATE EXTENSION pgautofailover CASCADE;
CREATE EXTENSION pg_search;
CREATE EXTENSION pgaudit;

-- pg_hint_plan 无需 CREATE EXTENSION，使用时执行 LOAD 'pg_hint_plan';
-- 查看已安装扩展：\dx 或 SELECT * FROM pg_extension;
```

## Upgrade

### 原地升级（`pg_upgrade --link`）

适用于同 Debian 底包（如 16/17/18）之间的大库升级。脚本会临时拼一个包含新旧两个版本二进制的镜像，跑完即删；旧数据目录会保留为 `*-bak`。

```bash
OLD_VER=17
NEW_VER=18
PARENT_DIR=/data
OLD_NAME=pg
NEW_NAME=pg-${NEW_VER}

docker pull sdrzlyz/pg:${OLD_VER}
docker pull sdrzlyz/pg:${NEW_VER}

docker build -t pg-upgrade:${OLD_VER}-to-${NEW_VER} - <<EOF
FROM sdrzlyz/pg:${OLD_VER} AS old
FROM sdrzlyz/pg:${NEW_VER}
COPY --from=old /usr/lib/postgresql/${OLD_VER} /usr/lib/postgresql/${OLD_VER}
COPY --from=old /usr/share/postgresql/${OLD_VER} /usr/share/postgresql/${OLD_VER}
EOF

docker stop pg
mkdir -p ${PARENT_DIR}/${NEW_NAME}

docker run --rm -v ${PARENT_DIR}:/pgdata --entrypoint bash pg-upgrade:${OLD_VER}-to-${NEW_VER} -c "
set -euo pipefail
OLD_DIR=/pgdata/${OLD_NAME}
NEW_DIR=/pgdata/${NEW_NAME}
chown postgres:postgres \${NEW_DIR} && chmod 700 \${NEW_DIR}

# 保持新旧库 data_checksums 一致（PG 18 默认开启，PG 17 默认关闭）
CHECKSUM=\$(gosu postgres /usr/lib/postgresql/${OLD_VER}/bin/pg_controldata \${OLD_DIR} | awk -F: '/Data page checksum version/ {gsub(/ /, \"\", \$2); print \$2}')
[ \"\${CHECKSUM}\" != \"0\" ] && CS_FLAG=--data-checksums || CS_FLAG=--no-data-checksums

gosu postgres /usr/lib/postgresql/${NEW_VER}/bin/initdb -D \${NEW_DIR} -U postgres --encoding=UTF8 --locale=en_US.utf8 \${CS_FLAG}
cp -a \${OLD_DIR}/pg_hba.conf \${NEW_DIR}/pg_hba.conf
grep '^shared_preload_libraries' \${OLD_DIR}/postgresql.conf >> \${NEW_DIR}/postgresql.conf || true

cd /tmp
gosu postgres /usr/lib/postgresql/${NEW_VER}/bin/pg_upgrade \
  -b /usr/lib/postgresql/${OLD_VER}/bin -B /usr/lib/postgresql/${NEW_VER}/bin \
  -d \${OLD_DIR} -D \${NEW_DIR} -U postgres --link --check

gosu postgres /usr/lib/postgresql/${NEW_VER}/bin/pg_upgrade \
  -b /usr/lib/postgresql/${OLD_VER}/bin -B /usr/lib/postgresql/${NEW_VER}/bin \
  -d \${OLD_DIR} -D \${NEW_DIR} -U postgres --link
"

mv ${PARENT_DIR}/${OLD_NAME} ${PARENT_DIR}/${OLD_NAME}-${OLD_VER}-bak
mv ${PARENT_DIR}/${NEW_NAME} ${PARENT_DIR}/${OLD_NAME}
docker rmi pg-upgrade:${OLD_VER}-to-${NEW_VER}
```

用新镜像 `sdrzlyz/pg:${NEW_VER}` 启动后，重新生成统计信息：

```bash
docker exec pg vacuumdb -U postgres --all --analyze-in-stages
```

### 逻辑导出导入

小库或跨不兼容版本（如 15 -> 18）直接 dump/restore 更省事：

```bash
docker exec pg pg_dumpall -U postgres > /data/pg_backup.sql
# 停旧库、备份目录、起新镜像空库后导入
docker exec -i pg psql -U postgres < /data/pg_backup.sql
```

## Notes

### PostgREST

```sql
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA PUBLIC TO web_anon;
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO web_anon;
```

### Citus

```sql
SELECT master_get_active_worker_nodes();

SET citus.shard_replication_factor = 2;

CREATE TABLE github_events (
    event_id bigint,
    event_type text,
    event_public boolean,
    repo_id bigint,
    payload jsonb,
    repo jsonb,
    actor jsonb,
    org jsonb,
    created_at timestamp
);

SELECT create_distributed_table('github_events', 'repo_id');

INSERT INTO github_events (event_id, event_type, event_public, repo_id, payload, repo, actor, org, created_at) VALUES
('1', '1', 't', '1', '1', '1', '1', '1', NULL),
('2', '2', 't', '2', '2', '2', '2', '2', NULL);
```

### References

- https://github.com/docker-library/postgres
- https://pigsty.io/zh/
- https://pgext.cloud/
- https://github.com/ApsaraDB/PolarDB-for-PostgreSQL
