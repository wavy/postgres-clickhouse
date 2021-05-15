#!/bin/sh

set -e
set -x

docker-compose exec clickhouse clickhouse-client -q 'CREATE TABLE default.demo_table (`id` Int64, `data` UUID) ENGINE = MergeTree() PRIMARY KEY (id);'
docker-compose exec clickhouse clickhouse-client -q "INSERT INTO default.demo_table (id, data) VALUES (0, generateUUIDv4())"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c 'IMPORT FOREIGN SCHEMA "default" FROM SERVER clickhouse_srv INTO public;'
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"
