ARG VERSION=6.2

# https://redislabs.com/redis-enterprise-software/download-center/modules/

# https://hub.docker.com/r/redislabs/redisearch/tags
FROM redislabs/redisearch:2.2.5 as redisearch
# https://hub.docker.com/r/redislabs/redisgraph/tags
FROM redislabs/redisgraph:2.4.12 as redisgraph
# https://hub.docker.com/r/redislabs/rejson/tags
FROM redislabs/rejson:2.0.4 as rejson
# https://hub.docker.com/r/redislabs/rebloom/tags
FROM redislabs/rebloom:2.2.9 as rebloom


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
COPY --from=rebloom /usr/lib/redis/modules/redisbloom.so ${LIBDIR}

USER 1001
