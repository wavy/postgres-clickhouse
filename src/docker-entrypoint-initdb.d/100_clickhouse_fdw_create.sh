#!/bin/bash

echo '[CLICKHOUSE] Initializing clickhouse_fdw extension'

create_sql=`mktemp`

cat <<EOF >${create_sql}
CREATE EXTENSION IF NOT EXISTS clickhouse_fdw;
EOF

psql -U "${POSTGRES_USER}" postgres -f ${create_sql}
if [ "${POSTGRES_DB:-postgres}" != 'postgres' ]; then  
  psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${create_sql}
fi

