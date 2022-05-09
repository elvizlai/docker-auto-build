FROM ubuntu:latest

# jemalloc
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates iputils-ping curl bzip2 build-essential \
    && mkdir -p /tmp/jemalloc-temp && cd /tmp/jemalloc-temp \
    && curl -s -L https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 -o jemalloc.tar.bz2 \
    && tar xjf ./jemalloc.tar.bz2 \
    && cd jemalloc-5.3.0 \
    && ./configure --with-jemalloc-prefix='je_' --with-malloc-conf='background_thread:true,metadata_thp:auto' \
    && make && make install \
    && apt-get purge --auto-remove -y curl bzip2 build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/*
