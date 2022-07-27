FROM sdrzlyz/alpine-glibc

ARG VERSION=4.0.1

# https://github.com/langhuihui/monibuca/tags
RUN wget https://github.com/langhuihui/monibuca/releases/download/v${VERSION}/m7s_${VERSION}_linux_amd64.tar.gz -O linux.tgz \
    && tar zxf linux.tgz \
    && rm -f linux.tgz

EXPOSE 8080

CMD exec /m7s
