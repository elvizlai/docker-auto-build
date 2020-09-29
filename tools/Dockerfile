FROM sdrzlyz/alpine

RUN apk add --update --no-cache \
    netcat-openbsd \
    tcpdump \
    && apk add --no-cache mycli --repository=http://mirrors.aliyun.com/alpine/edge/testing \
    && rm -rf /var/cache/apk/*
