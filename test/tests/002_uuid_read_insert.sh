#!/bin/sh

set -e
set -x

docker-compose exec clickhouse clickhouse-client -q 'CREATE TABLE default.demo_table (`id` Int64, `data` UUID) ENGINE = MergeTree() PRIMARY KEY (id);'
docker-compose exec clickhouse clickhouse-client -q "INSERT INTO default.demo_table (id, data) VALUES (0, '4995c48e-88a6-40ca-b6c5-b4018e0a7460')"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c 'IMPORT FOREIGN SCHEMA "default" FROM SERVER clickhouse_srv INTO public;'
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c "\d public.demo_table"

# Insert from postgres to clickhouse
docker-compose exec pg psql -U postgres -c "INSERT INTO public.demo_table (id, data) VALUES (1, '33bb9554-c616-42e6-a9c6-88d3bba4221c')"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
