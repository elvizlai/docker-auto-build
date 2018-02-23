FROM postgres:alpine

RUN apk add --no-cache --update-cache git make cmake libstdc++ g++

RUN git clone https://github.com/jaiminpan/pg_jieba \
    && cd pg_jieba && git submodule update --init --recursive \
    && mkdir build && cd build && cmake .. && make && make install \
    && rm -rf /pg_jieba && apk del git make cmake g++ && cd / \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone