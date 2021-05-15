#!/bin/sh

########################################################################################
#                                                                                      #
#  Syntax: ./build.sh <tag> <base image> <clickhouse_fdw git ref>                      #
#      ex: ./build.sh latest postgres:13-alpine tags/1.3.0                             #
#      ex: ./build.sh nightly postgres:13-alpine wavy                                  #
#      ex: ./build.sh timescaledb-latest timescale/timescaledb:latest-pg13 tags/1.3.0  #
#      ex: ./build.sh timescaledb-nightly timescale/timescaledb:latest-pg13 wavy       #
#                                                                                      #
########################################################################################

set -e
set -x

TAG="${1:-nightly}"
BASE_IMAGE="${2:-postgres:13-alpine}"
CLICKHOUSE_FDW_REF="${3:-wavy}"

if [ "$(uname -m)" = 'x86_64' ]; then
    docker build \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        --build-arg CLICKHOUSE_FDW_REF=${CLICKHOUSE_FDW_REF} \
        -t wavyfm/postgres-clickhouse:${TAG} .
else
    docker buildx build \
        --platform linux/amd64 \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        --build-arg CLICKHOUSE_FDW_REF=${CLICKHOUSE_FDW_REF} \
        -t wavyfm/postgres-clickhouse:${TAG} \
        --load .
fi
