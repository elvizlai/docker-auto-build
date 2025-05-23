Source

```
https://github.com/docker-library/postgres
```

Reference

```
https://pigsty.io/zh/
https://ext.pigsty.io

https://github.com/ApsaraDB/PolarDB-for-PostgreSQL
```

Single Node Example

```
docker run -itd \
    --restart always \
    --name pg \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    -p 5432:5432 \
    sdrzlyz/pg:13
```

PostgREST

```
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA PUBLIC TO web_anon;
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO web_anon;
```

Extension  
usage `psql -U postgres`

```
CREATE EXTENSION citus;

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis_tiger_geocoder;

# 需要先添加到 shared_preload_libraries
CREATE EXTENSION pglogical;

# 需要先添加到 shared_preload_libraries
CREATE EXTENSION pgautofailover CASCADE;

CREATE EXTENSION pgrouting;
CREATE EXTENSION timescaledb;

CREATE EXTENSION supabase_vault;

CREATE EXTENSION age;

# 需要先添加到 shared_preload_libraries
CREATE EXTENSION pg_search;

CREATE EXTENSION zombodb;

CREATE EXTENSION anon;

CREATE EXTENSION vector;

CREATE EXTENSION pg_cron;

CREATE EXTENSION pg_ivm;

CREATE EXTENSION pgmq;

CREATE EXTENSION orafce;

CREATE EXTENSION http;

CREATE EXTENSION zhparser;

# 需要先添加到 shared_preload_libraries
CREATE EXTENSION pgaudit;

# pg_hint_plan 不需要安装，使用时通过 LOAD 'pg_hint_plan';


-- \dx or SELECT * FROM pg_extension;
```

citus check node

```
select master_get_active_worker_nodes();
```

citus check

```
set citus.shard_replication_factor = 2;

CREATE TABLE github_events
(
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

INSERT INTO "github_events" ("event_id", "event_type", "event_public", "repo_id", "payload", "repo", "actor", "org", "created_at") VALUES
('1', '1', 't', '1', '1', '1', '1', '1', NULL),
('2', '2', 't', '2', '2', '2', '2', '2', NULL);
```

For pgml

```
apt install python3-pip
pip3 install xgboost
pip3 install lightgbm
```
