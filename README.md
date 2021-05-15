# postgres-clickhouse

A Docker image for [PostgreSQL](https://www.postgresql.org), the stable relational database, that can natively interact with [Clickhouse](https://clickhouse.tech), an incredibly fast columnar database.

Specifically, it is a PostgreSQL Docker image with the [clickhouse_fdw](https://github.com/wavy/clickhouse_fdw) extension included and configured automatically. There is also a secondary image for combining [TimescaleDB](https://www.timescale.com) and clickhouse_fdw in the same image.

This image will always target the latest stable release from Postgres (currently 13).

## Quick Start

A sample Docker Compose project is placed at the root of this project. It will spin up this image (`latest` tag), as well as the latest stable Clickhouse server.

```sh
# Download the repo and start Postgres and Clickhouse
git clone https://github.com/wavy/postgres-clickhouse
docker-compose up -d

# First, create the table in Clickhouse. Here we are creating a table with columns 'id' (Int64), and 'data' (String)
docker-compose exec clickhouse clickhouse-client -q 'CREATE TABLE default.demo_table (`id` Int64, `data` String) ENGINE = MergeTree() PRIMARY KEY (id);'

# Still on the Clickhouse side, we can add some data
docker-compose exec clickhouse clickhouse-client -q "INSERT INTO default.demo_table (id, data) VALUES (0, 'hello')"

# On the Postgres side, we can use the IMPORT FOREIGN SCHEMA statement to import all the tables from the "default" Clickhouse table into the "public" schema
docker-compose exec pg psql -U postgres -c 'IMPORT FOREIGN SCHEMA "default" FROM SERVER clickhouse_srv INTO public;'

# Still on the Postgres side, we can now fetch the existing data from Clickhouse
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table;"

# ... and we can add more data!
docker-compose exec pg psql -U postgres -c "INSERT INTO public.demo_table (id, data) VALUES (1, 'world');"

# Notice that Postgres and Clickhouse are in sync:
docker-compose exec pg psql -U postgres -c "SELECT * FROM public.demo_table ORDER BY id;"
docker-compose exec clickhouse clickhouse-client -q "SELECT * FROM default.demo_table ORDER BY id;"

# Tear down
docker-compose down
```

## Image

```sh
docker pull wavyfm/postgres-clickhouse:latest
```

Available tags:

- `latest`:: PostgreSQL 13, clickhouse_fdw 1.3.0
- `nightly`: PostgreSQL 13, and the latest update from clickhouse_fdw (built nightly).
- `timescaledb-latest`: PostgreSQL 13, latest stable TimescaleDB, clickhouse_fdw 1.3.0
- `timescaledb-nightly`: PostgreSQL 13, latest stable TimescaleDB, and the latest update from clickhouse_fdw (built nightly)

All images are based on Alpine (see base images for corresponding Alpine versions).

## Environment

Since this image is based on the default Postgres one, you can use the same environment variables to configure it. For example:

- `POSTGRES_USER`: changes the default user in Postgres from `postgres`
- `POSTGRES_PASSWORD`: sets a password on the default user
- `POSTGRES_DB`: changes the default database (usually `postgres`), owned by the default user

In addition, the following environment variables will configure clickhouse_fdw in Postgres:

- `CLICKHOUSE_FDW_HOST`: the hostname of the remote Clickhouse instance. If not set, clickhouse_fdw is still installed but not configured for any server
- `CLICKHOUSE_FDW_PORT`: the port of the remote Clickhouse instance. Defaults to 9000 (TCP interface), but you should change this to 8123 if you change the interface to `http` below
- `CLICKHOUSE_FDW_INTERFACE`: either `binary` or `http`. Defaults to `binary` (recommended for better performance)
- `CLICKHOUSE_FDW_DB`: the name of the corresponding database in Clickhouse. Defaults to `default` (which is usually the default Clickhouse DB name)
- `CLICKHOUSE_FDW_USER`: username for logging into Clickhouse. Defaults to `default`
- `CLICKHOUSE_FDW_PASSWORD`: optional password for logging into Clickhouse. Default is empty
- `CLICKHOUSE_FDW_SERVER_NAME`: overwrites the name of the SERVER definition in Postgres. Defaults to `clickhouse_srv`

## Is this production ready?

Probably not, but we are testing it for Big-Data analysis of music over at [wavy.fm](https://wavy.fm)!

## License

See LICENSE file. Copyright 2021 Wavy Labs Inc.
