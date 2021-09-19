FROM golang:1.17-buster

ENV GOPROXY "https://mirrors.tencent.com/go/|https://goproxy.cn|https://goproxy.io|direct"
ENV PATH $PATH:$GOPATH/bin

# runtime essential
RUN apt-get update && apt-get install --no-install-recommends -y unzip upx-ucl bzip2 jq

WORKDIR /root/go/src

# jemalloc
RUN mkdir -p /tmp/jemalloc-temp && cd /tmp/jemalloc-temp \
    && curl -s -L https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 -o jemalloc.tar.bz2 \
    && tar xjf ./jemalloc.tar.bz2 \
    && cd jemalloc-5.2.1 \
    && ./configure --with-jemalloc-prefix='je_' --with-malloc-conf='background_thread:true,metadata_thp:auto' \
    && make && make install

# docker kubectl buf protoc protoc-gen-go protoc-gen-grpc-gateway protoc-gen-openapiv2 revive protoc-gen-go-json protoc-gen-go-grpc protoc-gen-validate stringer
RUN cd /tmp \
    && curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.8.tgz | tar zxf - && mv docker/docker $GOPATH/bin/docker \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl $GOPATH/bin/ \
    && curl -sSL https://github.com/bufbuild/buf/releases/download/v0.56.0/buf-Linux-x86_64 > buf && chmod +x buf && mv buf $GOPATH/bin/ \
    && curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v3.17.3/protoc-3.17.3-linux-x86_64.zip > protoc.zip && unzip -q protoc.zip && mv bin/protoc $GOPATH/bin/ \
    && curl -sSL https://github.com/protocolbuffers/protobuf-go/releases/download/v1.27.1/protoc-gen-go.v1.27.1.linux.amd64.tar.gz | tar zxf - && chmod +x protoc-gen-go && mv protoc-gen-go $GOPATH/bin/ \
    && curl -sSL https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v2.6.0/protoc-gen-grpc-gateway-v2.6.0-linux-x86_64 > protoc-gen-grpc-gateway && chmod +x protoc-gen-grpc-gateway && mv protoc-gen-grpc-gateway $GOPATH/bin/ \
    && curl -sSL https://github.com/grpc-ecosystem/grpc-gateway/releases/download/v2.6.0/protoc-gen-openapiv2-v2.6.0-linux-x86_64 > protoc-gen-openapiv2 && chmod +x protoc-gen-openapiv2 && mv protoc-gen-openapiv2 $GOPATH/bin/ \
    && go get -v -u github.com/mgechev/revive \
    google.golang.org/grpc/cmd/protoc-gen-go-grpc \
    github.com/envoyproxy/protoc-gen-validate \
    golang.org/x/tools/cmd/stringer \
    && upx -f -q /usr/local/go/bin/* $GOPATH/bin/* || true

# clean
RUN apt-get purge --auto-remove -y unzip upx-ucl bzip2 \
    && rm -rf /root/go/src/* /root/go/pkg/* /root/.cache/go-build/* /tmp/* /var/lib/apt/lists/*
