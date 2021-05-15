#!/bin/bash


if [ -z "${CLICKHOUSE_FDW_HOST}" ]; then
    echo '[CLICKHOUSE] Environment variable "CLICKHOUSE_FDW_HOST" is not defined, server will not be initialized.'
    exit 0
fi

export CLICKHOUSE_FDW_DB="${CLICKHOUSE_FDW_DB}"
export CLICKHOUSE_FDW_HOST="${CLICKHOUSE_FDW_HOST}"
export CLICKHOUSE_FDW_PORT="${CLICKHOUSE_FDW_PORT:-9000}"
export CLICKHOUSE_FDW_USER="${CLICKHOUSE_FDW_USER:-default}"
export CLICKHOUSE_FDW_PASSWORD="${CLICKHOUSE_FDW_PASSWORD}"
export CLICKHOUSE_FDW_SERVER_NAME="${CLICKHOUSE_FDW_SERVER_NAME:-clickhouse_srv}"
export CLICKHOUSE_FDW_INTERFACE="${CLICKHOUSE_FDW_INTERFACE:-binary}"  # can also be 'http'

create_sql=`mktemp`

echo "[CLICKHOUSE] Creating server '${CLICKHOUSE_FDW_SERVER_NAME}' which connecting to ${CLICKHOUSE_FDW_HOST}:${CLICKHOUSE_FDW_PORT}/${CLICKHOUSE_FDW_DB}"
cat <<EOF >${create_sql}
CREATE SERVER IF NOT EXISTS "${CLICKHOUSE_FDW_SERVER_NAME}" FOREIGN DATA WRAPPER clickhouse_fdw OPTIONS (
  dbname '${CLICKHOUSE_FDW_DB}',
  host '${CLICKHOUSE_FDW_HOST}',
  port '${CLICKHOUSE_FDW_PORT}',
  driver '${CLICKHOUSE_FDW_INTERFACE}'
);
EOF

psql -U "${POSTGRES_USER}" postgres -f ${create_sql}
if [ "${POSTGRES_DB:-postgres}" != 'postgres' ]; then  
  psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${create_sql}
fi

echo "[CLICKHOUSE] Creating user mapping for Clickhouse user '${CLICKHOUSE_FDW_USER}'"
cat <<EOF >${create_sql}
CREATE USER MAPPING IF NOT EXISTS FOR CURRENT_USER SERVER "${CLICKHOUSE_FDW_SERVER_NAME}" OPTIONS (
  user '${CLICKHOUSE_FDW_USER}',
  password '${CLICKHOUSE_FDW_PASSWORD}'
);
EOF

psql -U "${POSTGRES_USER}" postgres -f ${create_sql}
if [ "${POSTGRES_DB:-postgres}" != 'postgres' ]; then  
  psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${create_sql}
fi

