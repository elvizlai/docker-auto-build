#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   update-extensions.sh [all | ext1,ext2,...]
# Defaults to ${AUTO_UPDATE_EXTENSIONS:-all} when called without arguments.

if [ "$(id -u)" = "0" ]; then
    exec gosu postgres "$0" "$@"
fi

TARGETS="${1:-${AUTO_UPDATE_EXTENSIONS-all}}"
case "${TARGETS}" in
    ""|off|OFF|false|FALSE|0|no|NO)
        echo "[update-extensions] Disabled (AUTO_UPDATE_EXTENSIONS=${TARGETS}), skipping."
        exit 0
        ;;
esac
PG_SUPERUSER="${POSTGRES_USER:-postgres}"
PGHOST_SOCKET="${PGHOST:-/var/run/postgresql}"

if [ -n "${POSTGRES_PASSWORD:-}" ] && [ -z "${PGPASSWORD:-}" ]; then
    export PGPASSWORD="${POSTGRES_PASSWORD}"
fi

psql_query() {
    local db="$1"
    local sql="$2"
    psql -X -h "${PGHOST_SOCKET}" -U "${PG_SUPERUSER}" -d "${db}" -At -v ON_ERROR_STOP=1 -c "${sql}"
}

# Skip read-only standbys / replicas (query via template1 to avoid hitting
# outdated timescaledb hooks if timescaledb is installed in the postgres DB)
in_recovery="$(psql_query template1 "SELECT pg_is_in_recovery();")"
if [ "${in_recovery}" = "t" ]; then
    echo "[update-extensions] Standby/recovery mode detected, skipping."
    exit 0
fi

should_update() {
    local ext="$1"
    if [ "${TARGETS}" = "all" ] || [ "${TARGETS}" = "true" ] || [ "${TARGETS}" = "1" ]; then
        return 0
    fi
    local IFS=','
    for item in ${TARGETS}; do
        # trim whitespace
        item="${item#"${item%%[![:space:]]*}"}"
        item="${item%"${item##*[![:space:]]}"}"
        if [ "${item}" = "${ext}" ]; then
            return 0
        fi
    done
    return 1
}

dbs="$(psql_query template1 "SELECT datname FROM pg_database WHERE datallowconn AND NOT datistemplate ORDER BY datname;")"
failed=0

while IFS= read -r db; do
    [ -z "${db}" ] && continue

    # TimescaleDB is in shared_preload_libraries and loads versioned timescaledb-<ver>.so
    # on ANY query (including pg_available_extensions). When upgrading across images where
    # the old .so no longer exists, ALTER EXTENSION timescaledb UPDATE MUST run first in a
    # fresh session before any SELECT, otherwise queries fail with:
    #   ERROR: could not access file "timescaledb-<old_ver>": No such file or directory
    # ALTER EXTENSION never creates an extension if it is not installed.
    if should_update "timescaledb"; then
        ts_out=""
        if ts_out="$(psql -X -h "${PGHOST_SOCKET}" -U "${PG_SUPERUSER}" -d "${db}" -v ON_ERROR_STOP=1 -c "ALTER EXTENSION timescaledb UPDATE;" 2>&1)"; then
            if ! printf '%s' "${ts_out}" | grep -q "already installed"; then
                echo "[update-extensions] [${db}] Updated timescaledb."
            fi
        elif ! printf '%s' "${ts_out}" | grep -q 'extension "timescaledb" does not exist'; then
            echo "[update-extensions] [${db}] ERROR: Failed to update timescaledb: ${ts_out}" >&2
            failed=1
            continue
        fi
    fi

    # Query installed extensions whose version differs from the default version.
    outdated=""
    if ! outdated="$(psql_query "${db}" "
        SELECT name || '|' || installed_version || '|' || default_version
        FROM pg_available_extensions
        WHERE installed_version IS NOT NULL
          AND installed_version <> default_version
        ORDER BY name;
    " 2>&1)"; then
        echo "[update-extensions] [${db}] ERROR: Failed to query extensions: ${outdated}" >&2
        failed=1
        continue
    fi

    [ -z "${outdated}" ] && continue

    postgis_upgraded=0

    while IFS='|' read -r ext cur_ver new_ver; do
        [ -z "${ext}" ] && continue
        if ! should_update "${ext}"; then
            continue
        fi

        case "${ext}" in
            postgis|postgis_raster|postgis_topology|postgis_sfcgal|postgis_tiger_geocoder)
                if [ "${postgis_upgraded}" = "1" ]; then
                    continue
                fi
                echo "[update-extensions] [${db}] Upgrading PostGIS extensions (${ext}: ${cur_ver} -> ${new_ver})..."
                if psql -X -h "${PGHOST_SOCKET}" -U "${PG_SUPERUSER}" -d "${db}" -v ON_ERROR_STOP=1 \
                    -c "SELECT postgis_extensions_upgrade();"; then
                    postgis_upgraded=1
                else
                    echo "[update-extensions] [${db}] ERROR: Failed to upgrade PostGIS extensions." >&2
                    failed=1
                fi
                ;;
            *)
                echo "[update-extensions] [${db}] Updating ${ext} (${cur_ver} -> ${new_ver})..."
                # Escape double quotes in identifier defensively
                ext_escaped="${ext//\"/\"\"}"
                if ! psql -X -h "${PGHOST_SOCKET}" -U "${PG_SUPERUSER}" -d "${db}" -v ON_ERROR_STOP=1 \
                    -c "ALTER EXTENSION \"${ext_escaped}\" UPDATE;"; then
                    echo "[update-extensions] [${db}] ERROR: Failed to update ${ext}." >&2
                    failed=1
                fi
                ;;
        esac
    done <<< "${outdated}"
done <<< "${dbs}"

if [ "${failed}" != "0" ]; then
    echo "[update-extensions] Completed with errors (some extensions were not updated)." >&2
    exit 1
fi

echo "[update-extensions] Done."
