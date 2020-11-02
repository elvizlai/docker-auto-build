FROM redis:latest

ENV DEPS "curl ca-certificates git build-essential unzip"

RUN set -ex;\
    apt-get update;\
	apt-get install -y --no-install-recommends $DEPS;

RUN mkdir /REJSON; \
    curl -sSL https://github.com/RedisLabsModules/rejson/archive/v1.0.5.tar.gz | tar zxvf - --strip-components 1 -C /REJSON; \
    cd /REJSON; \
    make;

# redis release
FROM bitnami/redis:5.0
ENV LIBDIR /opt/bitnami/redis/modules
RUN set -ex; \
    mkdir -p "$LIBDIR";
COPY --from=0 /REJSON/src/rejson.so "$LIBDIR"
