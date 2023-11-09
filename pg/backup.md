### SQL 转储

#### pg_dump 备份一个数据库

```bash
pg_dump -h localhost -p 5432 -U postgres -d postgres -f postgres.sql
```

#### pg_dumpall 备份所有数据库

```bash
pg_dumpall -h localhost -p 5432 -U postgres -f postgres.sql
```

#### pg_restore

```bash
pg_restore -h localhost -p 5432 -U postgres -d postgres -f postgres.sql
```


### 工具备份 [pgBackRest](https://github.com/pgbackrest/pgbackrest)
```
cat > /etc/pgbackrest/pgbackrest.conf <<EOF
[pg]
pg1-path=/var/lib/postgresql/data
pg1-port=5432
pg1-user=postgres
pg1-host-user=postgres

[global]
repo1-path=/var/lib/pgbackrest
repo1-retention-full=2
EOF
```

检查  /var/lib/postgresql/data/postgresql.conf 中的以下配置参数
```
# should be at least replica
wal_level = logical
archive_mode = on
# stanza should be the same as the stanza in /etc/pgbackrest/pgbackrest.conf
archive_command = 'pgbackrest --stanza=pg archive-push %p'


# one line command
sed -i "s/max_connections = 100/max_connections = 1000/;s/#wal_level = replica/wal_level = logical/;s/#archive_mode = off/archive_mode = on/;s/#archive_command = ''/archive_command = 'pgbackrest --stanza=pg archive-push %p'/" /var/lib/postgresql/data/postgresql.conf
```

```
# 初始化
pgbackrest --stanza=pg --log-level-console=info stanza-create
pgbackrest --stanza=pg --log-level-console=info check

# 备份
pgbackrest --stanza=pg --log-level-console=info backup

# 还原
pgbackrest --stanza=pg --log-level-console=info restore
```
```