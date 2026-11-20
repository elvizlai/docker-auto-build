ARG GO_VERSION=1.27.4
ARG VERSION=18
FROM golang:${GO_VERSION}-alpine AS tools

# https://github.com/timescale/timescaledb-docker/blob/main/Dockerfile
RUN apk add --no-cache git \
    && CGO_ENABLED=0 go install -ldflags="-s -w" github.com/timescale/timescaledb-tune/cmd/timescaledb-tune@latest \
    && CGO_ENABLED=0 go install -ldflags="-s -w" github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy@latest


FROM postgres:${VERSION}-bookworm

# set timezone
ENV TZ=PRC

# set default data dir (keeps PG 18+ compatible with /var/lib/postgresql/data volumes)
ENV PGDATA=/var/lib/postgresql/data

# pigsty https://pgext.cloud/
RUN printf 'APT::Install-Recommends "false";\nAPT::Install-Suggests "false";\n' > /etc/apt/apt.conf.d/99norecommends \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg \
    && curl -fsSL https://repo.pigsty.cc/key | gpg --dearmor -o /etc/apt/keyrings/pigsty.gpg \
    && . /etc/os-release \
    && echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && echo "deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.cc/apt/infra generic main" > /etc/apt/sources.list.d/pigsty.list \
    && echo "deb [signed-by=/etc/apt/keyrings/pigsty.gpg] https://repo.pigsty.cc/apt/pgsql/${VERSION_CODENAME} ${VERSION_CODENAME} main" >> /etc/apt/sources.list.d/pigsty.list \
    && curl -fsSL https://repo.pigsty.cc/pig | bash \
    && pig repo update \
    && pig ext add -y citus postgis postgis_tiger_geocoder pglogical pgautofailover hll topn pgrouting timescaledb timescaledb_toolkit pg_duckdb pg_mooncake \
        supabase_vault age pg_search vector pg_cron pg_ivm anon smlar vchord vchord_bm25 pgmq orafce http zhparser \
        pg_repack pgaudit pg_hint_plan wal2json decoder_raw \
    && apt-get autoremove -y --purge curl pig \
    && apt-get clean -y \
    && rm -rf \
        /root/.cache \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /var/log/*.log

# multi: using comma as spliter, example: shared_preload_libraries='citus,timescaledb'
# pgautofailover,pglogical
RUN echo "shared_preload_libraries='citus,pg_stat_statements,timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample

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

# add health check & extension update scripts
COPY --chmod=755 pg_healthcheck wait-for-manager.sh /
COPY --chmod=755 custom-entrypoint.sh update-extensions.sh /usr/local/bin/

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh#L338
RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

ENV TIMESCALEDB_TELEMETRY=off
ENV AUTO_UPDATE_EXTENSIONS=all

ENTRYPOINT ["custom-entrypoint.sh"]
CMD ["postgres"]

HEALTHCHECK --interval=4s --timeout=10s --retries=3 --start-period=6s CMD ["/pg_healthcheck"]
