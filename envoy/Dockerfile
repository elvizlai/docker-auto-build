ARG VERSION=1.18.3

FROM envoyproxy/envoy-alpine:v${VERSION}

COPY dep.sh /opt/
RUN ln -sf /usr/glibc-compat/lib/ld-2.33.so /usr/glibc-compat/lib/ld-linux-x86-64.so.2 \
    && chmod +x /opt/dep.sh && /opt/dep.sh

ADD https://x.morn.io/dl/envoy/envoy /usr/local/bin/envoy
RUN chmod +x /usr/local/bin/envoy

COPY envoy.yaml /etc/envoy/envoy.yaml
