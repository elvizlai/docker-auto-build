FROM timescale/timescaledb-postgis:latest-pg12

RUN apk add --no-cache --update-cache git make cmake libstdc++ g++

ENV TIMESCALEDB_TELEMETRY=off

RUN sed 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g' -i /etc/apk/repositories \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && git clone https://github.com/jaiminpan/pg_jieba \
    && cd pg_jieba && git submodule update --init --recursive \
    && mkdir build && cd build && cmake .. && make && make install \
    && rm -rf /pg_jieba && apk del git make cmake libstdc++ g++
