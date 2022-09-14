minial example
```
docker run -it --rm \
    --sysctl net.core.somaxconn=100000 \
    -m 1024m \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -p 6379:6379 \
    sdrzlyz/redis:7.0
```

example with args
```
docker run -it --rm \
    --sysctl net.core.somaxconn=100000 \
    -m 1024m \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -p 6379:6379 \
    sdrzlyz/redis:7.0 \
    /run.sh --maxclients 100000 --maxmemory 1024mb --maxmemory-policy volatile-lru
```

full modules example
```
docker run -it --rm \
    --sysctl net.core.somaxconn=10000 \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -p 6379:6379 \
    sdrzlyz/redis:7.0 \
    /run.sh --maxmemory 1G --maxmemory-policy allkeys-lru \
    --loadmodule /opt/modules/rejson.so \
    --loadmodule /opt/modules/redisbloom.so \
    --loadmodule /opt/modules/redisearch.so \
    --loadmodule /opt/modules/redisgraph.so \
    --loadmodule /opt/modules/tairhash.so \
    --loadmodule /opt/modules/tairstring.so \
    --loadmodule /opt/modules/tairzset.so \
    --loadmodule /opt/modules/rede.so
```