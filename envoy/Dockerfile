ARG VERSION=1.23.0

FROM envoyproxy/envoy-alpine:v1.21.4

COPY dep.sh /opt/
RUN chmod +x /opt/dep.sh && /opt/dep.sh

ADD https://x.morn.io/dl/envoy/envoy-1.23.0 /usr/local/bin/envoy
RUN chmod +x /usr/local/bin/envoy

COPY envoy.yaml /etc/envoy/envoy.yaml
