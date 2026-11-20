#!/usr/bin/env bash

set -Eeo pipefail

# Zero-race automatic extension upgrade wrapper around official docker-entrypoint.sh.
# Controlled via AUTO_UPDATE_EXTENSIONS env var (default: "all"):
#   - unset / "all" / "true" / "1": update all installed outdated extensions (default)
#   - "timescaledb" or "timescaledb,vector": update only listed extensions
#   - "" / "off" / "false" / "0" / "no": disabled

run_as_postgres() {
    if [ "$(id -u)" = "0" ]; then
        gosu postgres "$@"
    else
        "$@"
    fi
}

AUTO_UPDATE_TARGETS="${AUTO_UPDATE_EXTENSIONS-all}"

should_auto_update() {
    case "${AUTO_UPDATE_TARGETS}" in
        ""|off|OFF|false|FALSE|0|no|NO) return 1 ;;
    esac

    # Only run when starting postgres (not bash, psql, etc.)
    if [ $# -eq 0 ]; then
        return 1
    fi
    if [ "$1" != "postgres" ] && [ "${1#-}" = "$1" ]; then
        return 1
    fi

    # Only run on an existing initialized data directory matching PG_MAJOR
    if [ ! -s "${PGDATA}/PG_VERSION" ]; then
        return 1
    fi
    if [ "$(tr -d '[:space:]' < "${PGDATA}/PG_VERSION")" != "${PG_MAJOR}" ]; then
        return 1
    fi

    return 0
}

compute_ext_stamp() {
    {
        printf 'targets=%s\n' "${AUTO_UPDATE_TARGETS}"
        grep -H '^default_version' "/usr/share/postgresql/${PG_MAJOR}/extension/"*.control 2>/dev/null | sort
    } | sha256sum | awk '{print $1}'
}

if should_auto_update "$@"; then
    stamp_file="${PGDATA}/.ext_update_stamp"
    current_stamp="$(compute_ext_stamp)"
    saved_stamp=""
    if [ -f "${stamp_file}" ]; then
        saved_stamp="$(cat "${stamp_file}" 2>/dev/null || true)"
    fi

    if [ "${current_stamp}" != "${saved_stamp}" ]; then
        echo "[custom-entrypoint] Image extensions changed, checking for outdated extensions (${AUTO_UPDATE_TARGETS})..."

        if [ "$(id -u)" = "0" ]; then
            mkdir -p /var/run/postgresql
            chown -R postgres:postgres /var/run/postgresql
            chmod 2777 /var/run/postgresql
        fi

        tmp_started=0
        stop_temp_pg() {
            if [ "${tmp_started}" = "1" ]; then
                run_as_postgres pg_ctl -D "${PGDATA}" -m fast -w stop >/dev/null 2>&1 || true
                tmp_started=0
            fi
        }
        trap stop_temp_pg EXIT

        # Start temporary local-only PostgreSQL (no TCP port exposed yet -> zero race window)
        run_as_postgres pg_ctl -D "${PGDATA}" -o "-c listen_addresses=''" -w start
        tmp_started=1

        if [ -n "${POSTGRES_PASSWORD:-}" ] && [ -z "${PGPASSWORD:-}" ]; then
            export PGPASSWORD="${POSTGRES_PASSWORD}"
        fi

        in_recovery="$(run_as_postgres psql -X -h /var/run/postgresql -U "${POSTGRES_USER:-postgres}" -d template1 -At -c "SELECT pg_is_in_recovery();")"

        update_ok=1
        if ! run_as_postgres /usr/local/bin/update-extensions.sh "${AUTO_UPDATE_TARGETS}"; then
            update_ok=0
            echo "[custom-entrypoint] WARNING: Some extension updates failed; continuing PostgreSQL startup (will retry on next restart)." >&2
        fi

        stop_temp_pg
        trap - EXIT

        if [ "${in_recovery}" != "t" ] && [ "${update_ok}" = "1" ]; then
            run_as_postgres bash -c 'printf "%s\n" "$1" > "$2"' _ "${current_stamp}" "${stamp_file}"
        fi
    fi
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
