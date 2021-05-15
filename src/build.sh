#!/bin/sh

########################################################################################
#                                                                                      #
#  Syntax: ./build.sh <tag> <base image> <clickhouse_fdw git ref>                      #
#      ex: ./build.sh latest postgres:13-alpine tags/1.3.0                             #
#      ex: ./build.sh nightly postgres:13-alpine master                                #
#      ex: ./build.sh timescaledb-latest timescale/timescaledb:latest-pg13 tags/1.3.0  #
#      ex: ./build.sh timescaledb-nightly timescale/timescaledb:latest-pg13 master     #
#                                                                                      #
#  Note: PUSH=1 must be set to push to Docker Hub.                                     #
#                                                                                      #
########################################################################################

set -e
set -x

TAG="${1:-latest}"
BASE_IMAGE="${2:-postgres:13-alpine}"
CLICKHOUSE_FDW_REF="${3:-tags/1.3.0}"

if [ "$(uname -m)" == 'x86_64' ]; then
    docker build \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        --build-arg CLICKHOUSE_FDW_REF=${CLICKHOUSE_FDW_REF} \
        -t wavyfm/postgres-clickhouse:${TAG} .

    if [ "$PUSH" == '1' ]; then
        docker push wavyfm/postgres-clickhouse:${TAG}
    fi
else
    if [ "$PUSH" == '1' ]; then
        ACTION=--push
    else
        ACTION=--load
    fi

    docker buildx build \
        --platform linux/amd64 \
        --build-arg BASE_IMAGE=${BASE_IMAGE} \
        --build-arg CLICKHOUSE_FDW_REF=${CLICKHOUSE_FDW_REF} \
        -t wavyfm/postgres-clickhouse:${TAG} \
        ${ACTION} .
fi
