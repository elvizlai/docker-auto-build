FROM alpine

RUN sed 's#https://dl-cdn.alpinelinux.org#https://mirrors.cloud.tencent.com#g' -i /etc/apk/repositories \
    && apk --update --no-cache add ca-certificates tzdata curl \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*
