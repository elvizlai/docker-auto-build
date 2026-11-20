#!/bin/bash

set -e

CONF_FILE="${POSTGRESQL_CONF_DIR:-$PGDATA}/postgresql.conf"

sed -i \
    -e "s/max_connections = [0-9]\+/max_connections = 1000/" \
    -e "s/#wal_level = replica/wal_level = logical/" \
    "${CONF_FILE}"

echo "cron.timezone = 'PRC'" >> "${CONF_FILE}"
