minial example
```
docker run -it --rm \
    --sysctl net.core.somaxconn=100000 \
    -m 1024m \
    -p 6379:6379 \
    sdrzlyz/redis:8.2
```

example with args
```
docker run -it --rm \
    --sysctl net.core.somaxconn=100000 \
    -m 1024m \
    -p 6379:6379 \
    sdrzlyz/redis:8.2 \
    redis-server --maxclients 100000 --maxmemory 1024mb --maxmemory-policy volatile-lru
```

full modules example
```
docker run -it --rm \
    --sysctl net.core.somaxconn=10000 \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -p 6379:6379 \
    sdrzlyz/redis:8.2 \
    redis-server --maxmemory 1G --maxmemory-policy allkeys-lru \
    --loadmodule /opt/modules/redisgraph.so \
    --loadmodule /opt/modules/tairhash.so \
    --loadmodule /opt/modules/tairstring.so \
    --loadmodule /opt/modules/tairzset.so \
    --loadmodule /opt/modules/rede.so
```

~~full modules example~~
```
docker run -it --rm \
    --sysctl net.core.somaxconn=10000 \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -p 6379:6379 \
    sdrzlyz/redis:7.2 \
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
