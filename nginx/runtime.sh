#!/usr/bin/env sh

apk add --no-cache \
  curl \
  ca-certificates \
  `# Bring in tzdata so users could set the timezones through the environment variables` \
  tzdata \
  `# Dependencies` \
  pcre \
  libgcc \
  libintl \
  `# ngx_http_image_filter_module` \
  libgd fontconfig libxpm tiff libavif \
  `# ngx_http_xslt_filter_module` \
  libxslt \
  `# ModSecurity dependencies` \
  libstdc++ \
  libmaxminddb-dev \
  geoip-dev \
  libxml2-dev \
  lmdb-dev \
  yaml-dev \
  `# luarocks` \
  unzip \
  outils-md5

apk add --no-cache --virtual .build-deps \
  make \
  gcc \
  libc-dev

LUAJIT=v2.1-20240815
LUAROCKS=3.11.1

mkdir -p /tmp/lib-src && cd /tmp/lib-src

# lua-jit https://github.com/openresty/luajit2/tags
mkdir -p luajit2.1
curl -sSL https://github.com/openresty/luajit2/archive/$LUAJIT.tar.gz | tar zxf - -C luajit2.1 --strip-components 1
cd luajit2.1
make -j$(nproc) && make install && cd ..

# luarocks https://luarocks.org
curl -sSL http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS.tar.gz | tar zxf -
cd luarocks-$LUAROCKS
./configure --lua-suffix=jit
make -j$(nproc) && make install && cd ..

# remove lua downloader wget
# https://github.com/luarocks/luarocks/issues/952#issuecomment-1184445229
sed -i '/WGET/d' /usr/local/share/lua/5.1/luarocks/fs/tools.lua

# pl https://github.com/lunarmodules/Penlight
# it deps on luafilesystem https://github.com/keplerproject/luafilesystem
luarocks install penlight

# date https://github.com/Tieske/date
luarocks install date

# lyaml
luarocks install lyaml

mkdir -p /var/log/nginx /var/cache/nginx/client_temp  

touch /var/log/nginx/access.log /var/log/nginx/stream.log /var/log/nginx/error.log

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stdout /var/log/nginx/stream.log
ln -sf /dev/stderr /var/log/nginx/error.log

apk del .build-deps && rm -rf /tmp/* /var/cache/apk/*
