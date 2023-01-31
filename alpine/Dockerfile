FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk --update --no-cache add ca-certificates tzdata curl \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*
