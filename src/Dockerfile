# syntax=docker/dockerfile:1

ARG BASE_IMAGE
FROM $BASE_IMAGE

RUN apk add --no-cache --virtual .build-deps make cmake build-base git
RUN apk add --no-cache --virtual .runtime-deps coreutils curl-dev util-linux-dev

WORKDIR /opt/build
RUN git clone https://github.com/wavy/clickhouse_fdw /opt/build/clickhouse_fdw
ARG CLICKHOUSE_FDW_REF
RUN cd /opt/build/clickhouse_fdw && git checkout $CLICKHOUSE_FDW_REF

WORKDIR /opt/build/clickhouse_fdw/build
RUN cmake .. && make && make install

# Cleanup
WORKDIR /
RUN apk del .build-deps
RUN rm -r /opt/build

COPY ./docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/
