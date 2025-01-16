FROM golang:1.19-bullseye as builder

ARG VERSION=1.5.5

RUN cd /tmp \
    && curl -sSL https://github.com/prest/prest/archive/refs/tags/v${VERSION}.tar.gz | tar zxf - \
    && cd prest-${VERSION} \
    && export GOPROXY="https://goproxy.cn|https://goproxy.io|https://goproxy.bj.bcebos.com|https://mirrors.tencent.com/go/|direct" \
    && go build github.com/prest/prest/cmd/prestd \
    && mv prestd /tmp/prestd

FROM golang:1.19-bullseye

COPY --from=builder /tmp/prestd /bin/prestd
COPY ./etc/entrypoint.sh /app/entrypoint.sh
COPY ./etc/prest.toml /app/prest.toml
COPY ./etc/plugin /app/plugin

WORKDIR /app

ENTRYPOINT ["sh", "/app/entrypoint.sh"]
