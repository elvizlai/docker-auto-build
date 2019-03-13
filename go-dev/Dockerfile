FROM sdrzlyz/alpine-glibc

# build and runtime essential
RUN apk --update --no-cache add curl git make bash upx

ARG GO_VER=1.12
ENV GOPATH /root/go
ENV GOPROXY "https://goproxy.io"
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

RUN curl -sSL https://dl.google.com/go/go$GO_VER.linux-amd64.tar.gz | tar zxf - && mv go /usr/local/go && mkdir -p $GOPATH/bin

WORKDIR /root/go/src

# docker kubectl
# protoc protoc-gen-go
# revive statik
RUN cd /tmp \
    && curl -sSL https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz | tar zxf - && mv docker/docker $GOPATH/bin/docker \
    && curl -sSL https://dl.k8s.io/v1.13.4/kubernetes-client-linux-amd64.tar.gz | tar zxf - && mv kubernetes/client/bin/kubectl $GOPATH/bin/kubectl && mkdir ~/.kube \
    && curl -sSL https://github.com/google/protobuf/releases/download/v3.7.0/protoc-3.7.0-linux-x86_64.zip > protoc.zip && unzip -q protoc.zip && mv bin/protoc $GOPATH/bin/protoc \
    && go get -d -u github.com/golang/protobuf/protoc-gen-go \
    && git -C /root/go/src/github.com/golang/protobuf checkout v1.3.0 \
    && go install github.com/golang/protobuf/protoc-gen-go \
    && go get -u github.com/mgechev/revive \
    && go get -u github.com/rakyll/statik \
    && upx -f -q /usr/local/go/bin/* $GOPATH/bin/* || true \
    && apk del upx \
    && rm -rf /root/go/src/* /root/go/pkg/* /root/.cache/go-build/* /tmp/*
