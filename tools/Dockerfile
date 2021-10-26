FROM sdrzlyz/alpine

RUN apk add --update --no-cache netcat-openbsd tcpdump py3-pip \
    && apk add --no-cache --virtual .build-deps musl-dev gcc python3-dev \
    && apk add --no-cache py3-pyperclip --repository=https://mirrors.cloud.tencent.com/alpine/edge/community \
    && apk add --no-cache mycli pgcli --repository=https://mirrors.cloud.tencent.com/alpine/edge/testing \
    && pip install pendulum setproctitle cli_helpers --upgrade \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
