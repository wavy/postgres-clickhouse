#!/bin/sh

set -e
set -x

docker-compose exec clickhouse clickhouse-client -q 'CREATE TABLE default.demo_table (`id` Int64, `data` Nullable(UUID)) ENGINE = MergeTree() PRIMARY KEY (id);'
docker-compose exec clickhouse clickhouse-client -q "INSERT INTO default.demo_table (id, data) VALUES (0, '7fe5c030-d299-41ba-91fa-f9b9f094af2a');" 
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c 'IMPORT FOREIGN SCHEMA "default" FROM SERVER clickhouse_srv INTO public;'
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c "\d public.demo_table"

# Insert from postgres to clickhouse
docker-compose exec pg psql -U postgres -c "INSERT INTO public.demo_table (id, data) VALUES (1, NULL)"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"

# Insert a non-null value
docker-compose exec pg psql -U postgres -c "INSERT INTO public.demo_table (id, data) VALUES (2, 'c2614918-449d-464f-8580-8afcd92bc3d1')"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"

# Get null values
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table WHERE data IS NULL ORDER BY id;"

# Get non-null values
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table WHERE data IS NOT NULL ORDER BY id;"

