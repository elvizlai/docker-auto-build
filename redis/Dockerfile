ARG VERSION=7.0

# https://docs.redis.com/latest/modules/

# https://hub.docker.com/r/redislabs/rejson/tags https://redis.io/docs/stack/json/
FROM redislabs/rejson:2.6.1 as rejson
# https://hub.docker.com/r/redislabs/rebloom/tags https://redis.io/docs/stack/bloom/
FROM redislabs/rebloom:2.6.0 as rebloom
# https://hub.docker.com/r/redislabs/redisearch/tags https://redis.io/docs/stack/search/
FROM redislabs/redisearch:2.8.2 as redisearch
# https://hub.docker.com/r/redislabs/redisgraph/tags https://redis.io/docs/stack/graph/
FROM redislabs/redisgraph:2.12.1 as redisgraph

# https://github.com/alibaba/TairString
FROM tairmodule/tairstring:latest as tairstring
# https://github.com/alibaba/TairZset
FROM tairmodule/tairzset:latest as tairzset

# Tairhash + ReDe compile
# https://github.com/alibaba/TairHash
# https://github.com/TamarLabs/ReDe
FROM redis:${VERSION} as tairhash
RUN set -ex; \
    \
    BUILD_DEPS=' \
        ca-certificates \
        cmake \
        gcc \
        git \
        g++ \
        make \
        curl \
    '; \
    apt-get update; \
    apt-get install -y $BUILD_DEPS --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    git clone "https://github.com/alibaba/TairHash.git"; \
    cd TairHash; \
    mkdir -p build; \
    cd build; \
    cmake -DSORT_MODE=yes ..; \
    make -j; \
    cd ..; \
    cp lib/tairhash_module.so /usr/local/lib/; \
    curl -sSL -o /usr/local/lib/rede.so https://github.com/TamarLabs/ReDe/releases/download/v0.5.0/module.so; \
    chmod +x /usr/local/lib/*.so

# provide GLIBC_2.29
FROM redis:${VERSION} as redis

# redis release
FROM bitnami/redis:${VERSION}

ARG DEPS="ca-certificates libgomp1"
ENV LIBDIR /opt/modules

# Required to perform privileged actions
USER 0

RUN set -ex; \
    apt-get update; \
	apt-get install -y --no-install-recommends ${DEPS}; \
    mkdir -p ${LIBDIR};

COPY --from=redis /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm-2.31.so /lib/x86_64-linux-gnu/
COPY --from=rejson /usr/lib/redis/modules/rejson.so ${LIBDIR}
COPY --from=redisearch /usr/lib/redis/modules/redisearch.so ${LIBDIR}
COPY --from=redisgraph /usr/lib/redis/modules/redisgraph.so ${LIBDIR}
COPY --from=rebloom /usr/lib/redis/modules/redisbloom.so ${LIBDIR}
COPY --from=tairhash /usr/local/lib/rede.so ${LIBDIR}/rede.so
COPY --from=tairstring /usr/local/lib/tairstring_module.so ${LIBDIR}/tairstring.so
COPY --from=tairhash /usr/local/lib/tairhash_module.so ${LIBDIR}/tairhash.so
COPY --from=tairzset /usr/local/lib/tairzset_module.so ${LIBDIR}/tairzset.so

USER 1001
