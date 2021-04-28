ARG VERSION=1.18.2

FROM envoyproxy/envoy-alpine:v${VERSION}

COPY dep.sh /opt/
RUN chmod +x /opt/dep.sh && /opt/dep.sh

COPY envoy /usr/local/bin/envoy
RUN chmod +x /usr/local/bin/envoy
