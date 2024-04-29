FROM alpine:3.19 AS builder

ARG VERSION=1.26.0

COPY build-stable.sh /opt/build.sh

RUN sh /opt/build.sh $VERSION


FROM alpine:3.19

COPY runtime.sh /opt/runtime.sh
RUN sh /opt/runtime.sh

COPY --from=builder /usr/sbin/nginx /usr/sbin/
COPY --from=builder /etc/nginx/ /etc/nginx/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/bin/envsubst /usr/local/bin/

COPY cors.conf /etc/nginx

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
