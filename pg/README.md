usage `psql -U postgres`
```
CREATE EXTENSION IF NOT EXISTS citus CASCADE;
CREATE EXTENSION IF NOT EXISTS cstore_fdw CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis CASCADE;
CREATE EXTENSION IF NOT EXISTS pgrouting CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- \dx or SELECT * FROM pg_extension;
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
