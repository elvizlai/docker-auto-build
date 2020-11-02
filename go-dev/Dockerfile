FROM golang:1.15-buster

ENV GOPROXY "https://goproxy.cn|https://gocenter.io|direct"
ENV PATH $PATH:$GOPATH/bin

# runtime essential
RUN apt-get update && apt-get install --no-install-recommends -y unzip upx-ucl

WORKDIR /root/go/src

# docker protoc revive
RUN cd /tmp \
    && curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-19.03.9.tgz | tar zxf - && mv docker/docker $GOPATH/bin/docker \
    && curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protoc-3.13.0-linux-x86_64.zip > protoc.zip && unzip -q protoc.zip && mv bin/protoc $GOPATH/bin/protoc \
    && go get -u github.com/mgechev/revive \
    && upx -f -q /usr/local/go/bin/* $GOPATH/bin/* || true \
    && apt-get purge --auto-remove -y upx-ucl \
    && rm -rf /root/go/src/* /root/go/pkg/* /root/.cache/go-build/* /tmp/* /var/lib/apt/lists/*
