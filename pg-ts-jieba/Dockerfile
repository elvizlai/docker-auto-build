FROM timescale/timescaledb-postgis:latest-pg12

RUN apk add --no-cache --update-cache git make cmake libstdc++ g++ perl boost-dev

ENV TIMESCALEDB_TELEMETRY=off

# https://github.com/jaiminpan/pg_jieba
# https://github.com/pgRouting/pgrouting
RUN sed 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' -i /etc/apk/repositories \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && git clone https://github.com/jaiminpan/pg_jieba \
    && cd pg_jieba && git submodule update --init --recursive \
    && mkdir build && cd build && cmake .. && make && make install && cd ../.. \
    && git clone -b v3.1.2 --depth=1 https://github.com/pgRouting/pgrouting \
    && cd pgrouting \
    && mkdir build && cd build && cmake .. && make && make install && cd ../.. \
    && rm -rf /pg_jieba /pgrouting && apk del git make cmake libstdc++ g++ perl boost-dev
