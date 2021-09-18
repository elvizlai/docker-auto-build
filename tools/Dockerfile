FROM sdrzlyz/alpine

RUN apk add --update --no-cache \
    netcat-openbsd tcpdump postgresql-client \
    && apk add --no-cache py3-pyperclip --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk add --no-cache mycli --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && apk add --no-cache pgcli --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && rm -rf /var/cache/apk/*
