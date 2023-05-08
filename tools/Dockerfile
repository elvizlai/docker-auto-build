FROM alpine

RUN apk add --update --no-cache musl-dev netcat-openbsd tcpdump py3-pip \
    && apk add --no-cache --virtual .build-deps gcc python3-dev \
    && apk add --no-cache py3-pyperclip py3-humanize \
    && apk add --no-cache mycli pgcli --repository=https://mirrors.ustc.edu.cn/alpine/edge/testing \
    && pip install pendulum setproctitle cli_helpers --upgrade \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
