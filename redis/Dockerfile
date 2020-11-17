ARG VERSION=5.0

# https://redislabs.com/redis-enterprise-software/download-center/modules/

# https://hub.docker.com/r/redislabs/redisearch
FROM redislabs/redisearch:1.6.13 as redisearch
# https://hub.docker.com/r/redislabs/redisgraph
FROM redislabs/redisgraph:2.2.5 as redisgraph
# https://hub.docker.com/r/redislabs/rejson
FROM redislabs/rejson:1.0.4 as rejson
# https://hub.docker.com/r/redislabs/redistimeseries
FROM redislabs/redistimeseries:1.4.3 as redistimeseries
# https://hub.docker.com/r/redislabs/rebloom
FROM redislabs/rebloom:2.2.4 as rebloom


# redis release
FROM bitnami/redis:${VERSION}

ARG DEPS="ca-certificates libgomp1"
ENV LIBDIR /opt/modules

# Required to perform privileged actions
USER 0

RUN set -ex;\
    apt-get update;\
	apt-get install -y --no-install-recommends ${DEPS}; \
    mkdir -p ${LIBDIR};

COPY --from=redisearch /usr/lib/redis/modules/redisearch.so ${LIBDIR}
COPY --from=redisgraph /usr/lib/redis/modules/redisgraph.so ${LIBDIR}
COPY --from=rejson /usr/lib/redis/modules/rejson.so ${LIBDIR}
COPY --from=redistimeseries /usr/lib/redis/modules/redistimeseries.so ${LIBDIR}
COPY --from=rebloom /usr/lib/redis/modules/redisbloom.so ${LIBDIR}

USER 1001
