FROM sdrzlyz/alpine

RUN apk add --update --no-cache netcat-openbsd tcpdump postgresql-client \
    && apk add --no-cache py3-pyperclip --repository=https://mirrors.cloud.tencent.com/alpine/edge/community \
    && apk add --no-cache mycli pgcli --repository=https://mirrors.cloud.tencent.com/alpine/edge/testing \
    && rm -rf /var/cache/apk/*
