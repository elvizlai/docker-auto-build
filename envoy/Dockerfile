ARG VERSION=1.17.1

FROM envoyproxy/envoy-alpine:v${VERSION}

COPY dep.sh /opt/

RUN chmod +x /opt/dep.sh && /opt/dep.sh

COPY envoy /usr/local/bin/envoy
