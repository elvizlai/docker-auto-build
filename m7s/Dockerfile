FROM sdrzlyz/alpine-glibc

ARG VERSION=3.0.0

RUN wget https://github.com/langhuihui/monibuca/releases/download/v${VERSION}/linux.tgz \
    && tar zxf linux.tgz \
    && rm -f linux.tgz

CMD exec /m7s_linux_x86_64
