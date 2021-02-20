FROM envoyproxy/envoy-alpine:v1.17.0

COPY dep.sh /opt/

RUN chmod +x /opt/dep.sh && /opt/dep.sh

COPY envoy /usr/local/bin/envoy
