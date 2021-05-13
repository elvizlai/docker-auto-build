#!/usr/bin/env sh

set -e

mkdir -p /opt/lib-src && cd /opt/lib-src

apk add --virtual build_deps curl make gcc libc-dev readline-dev ncurses-dev

apk add unzip outils-md5

LUAJIT=v2.1-20210510
LUAROCKS=3.7.0

# lua-jit https://github.com/openresty/luajit2
mkdir -p luajit2.1
curl -sSL https://github.com/openresty/luajit2/archive/$LUAJIT.tar.gz | tar zxf - -C luajit2.1 --strip-components 1
cd luajit2.1
make -j4 && make install && cd ..

# luarocks
curl -sSL http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS.tar.gz | tar zxf -
cd luarocks-$LUAROCKS
./configure
make && make install && cd .. && rm -rf luarocks-$LUAROCKS

# luasocket
luarocks install luasocket

# cjson
LUA_CJSON=2.1.0.8
curl -sSL https://github.com/openresty/lua-cjson/archive/$LUA_CJSON.tar.gz | tar zxf -
cd lua-cjson-$LUA_CJSON && luarocks make && rm -rf lua-cjson-*

# remove
apk del build_deps
