FROM golang:1.15-buster

ENV GOPROXY "https://goproxy.cn|https://gocenter.io|direct"
ENV PATH $PATH:$GOPATH/bin

# runtime essential
RUN apt-get update && apt-get install --no-install-recommends -y unzip upx-ucl bzip2

WORKDIR /root/go/src

# jemalloc
RUN mkdir -p /tmp/jemalloc-temp && cd /tmp/jemalloc-temp \
    && curl -s -L https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 -o jemalloc.tar.bz2 \
    && tar xjf ./jemalloc.tar.bz2 \
    && cd jemalloc-5.2.1 \
    && ./configure --with-jemalloc-prefix='je_' --with-malloc-conf='background_thread:true,metadata_thp:auto' \
    && make && make install

# docker protoc revive
RUN cd /tmp \
    && curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.1.tgz | tar zxf - && mv docker/docker $GOPATH/bin/docker \
    && curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/protoc-3.14.0-linux-x86_64.zip > protoc.zip && unzip -q protoc.zip && mv bin/protoc $GOPATH/bin/protoc \
    && go get -u github.com/mgechev/revive \
    && upx -f -q /usr/local/go/bin/* $GOPATH/bin/* || true

# clean
RUN apt-get purge --auto-remove -y upx-ucl bzip2 \
    && rm -rf /root/go/src/* /root/go/pkg/* /root/.cache/go-build/* /tmp/* /var/lib/apt/lists/*
