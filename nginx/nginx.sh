#!/usr/bin/env bash

yum install -y which patch libxml2-devel libxslt-devel gd-devel GeoIP GeoIP-devel GeoIP-data

NGINXVER=${1:-1.18.0}
NGINXNJS=0.5.0
NGINXDIR=/opt/nginx-$NGINXVER
NGINXNDK=0.3.1
NGINXLUA=0.10.19

mkdir -p $NGINXDIR/module && cd $NGINXDIR/module

rm -rf ngx_brotli
git clone https://github.com/google/ngx_brotli
cd ngx_brotli
git submodule update --init
cd ..

git clone -b $NGINXNJS https://github.com/nginx/njs

curl -sSL https://github.com/simplresty/ngx_devel_kit/archive/v$NGINXNDK.tar.gz | tar zxf -

# https://github.com/openresty/lua-nginx-module
curl -sSL https://github.com/openresty/lua-nginx-module/archive/v$NGINXLUA.tar.gz | tar zxf -

# dynamic modules
rm -rf $NGINXDIR/module/dynamic
mkdir -p $NGINXDIR/module/dynamic
cd $NGINXDIR/module/dynamic
git clone https://github.com/ADD-SP/ngx_waf
git clone https://github.com/winshining/nginx-http-flv-module
git clone https://github.com/arut/nginx-ts-module
git clone https://github.com/openresty/echo-nginx-module
git clone https://github.com/openresty/headers-more-nginx-module
git clone https://github.com/openresty/srcache-nginx-module
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module

cd $NGINXDIR
curl -sSL https://nginx.org/download/nginx-$NGINXVER.tar.gz | tar zxf - -C . --strip-components 1
# curl -sSL https://x.morn.io/dl/nginx-$NGINXVER.tgz | tar zxf - -C . --strip-components 1

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1
./configure \
    --with-cc-opt="-DTCP_FASTOPEN=23" \
    --with-ld-opt="-ljemalloc -Wl,-rpath,$LUAJIT_LIB" \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre-jit \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --add-module=./module/ngx_brotli \
    --add-module=./module/njs/nginx \
    --add-module=./module/ngx_devel_kit-$NGINXNDK \
    --add-module=./module/lua-nginx-module-$NGINXLUA \
    --add-dynamic-module=./module/dynamic/ngx_waf \
    --add-dynamic-module=./module/dynamic/nginx-http-flv-module \
    --add-dynamic-module=./module/dynamic/nginx-ts-module \
    --add-dynamic-module=./module/dynamic/echo-nginx-module \
    --add-dynamic-module=./module/dynamic/headers-more-nginx-module \
    --add-dynamic-module=./module/dynamic/srcache-nginx-module \
    --add-dynamic-module=./module/dynamic/ngx_http_substitutions_filter_module

make -j$(nproc)
# make -j$(nproc) -f objs/Makefile modules

make install

# remove source
rm -rf /opt/*

# delete old modules
rm -f /etc/nginx/modules/*.so.old || true

# https://github.com/bungle/awesome-resty

# lualib module
mkdir -p /etc/nginx/lualib
cd /etc/nginx/lualib

LUA_RESTY_CORE=0.1.21
curl -sSL https://github.com/openresty/lua-resty-core/archive/v$LUA_RESTY_CORE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-core-$LUA_RESTY_CORE/lib/* .
rm -rf lua-resty-core-$LUA_RESTY_CORE

LUA_RESTY_STRING=0.12
curl -sSL https://github.com/openresty/lua-resty-string/archive/v$LUA_RESTY_STRING.tar.gz | tar zxf -
/bin/cp -rf lua-resty-string-$LUA_RESTY_STRING/lib/* .
rm -rf lua-resty-string-$LUA_RESTY_STRING

LUA_RESTY_CACHE=0.10
curl -sSL https://github.com/openresty/lua-resty-lrucache/archive/v$LUA_RESTY_CACHE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-lrucache-$LUA_RESTY_CACHE/lib/* .
rm -rf lua-resty-lrucache-$LUA_RESTY_CACHE

LUA_RESTY_LOCK=0.08
curl -sSL https://github.com/openresty/lua-resty-lock/archive/v$LUA_RESTY_LOCK.tar.gz | tar zxf -
/bin/cp -rf lua-resty-lock-$LUA_RESTY_LOCK/lib/* .
rm -rf lua-resty-lock-$LUA_RESTY_LOCK

LUA_RESTY_MLCACHE=2.4.1
curl -sSL https://github.com/thibaultcha/lua-resty-mlcache/archive/$LUA_RESTY_MLCACHE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-mlcache-$LUA_RESTY_MLCACHE/lib/* .
rm -rf lua-resty-mlcache-$LUA_RESTY_MLCACHE

LUA_RESTY_WEBSOCKET=0.08
curl -sSL https://github.com/openresty/lua-resty-websocket/archive/v$LUA_RESTY_WEBSOCKET.tar.gz | tar zxf -
/bin/cp -rf lua-resty-websocket-$LUA_RESTY_WEBSOCKET/lib/* .
rm -rf lua-resty-websocket-$LUA_RESTY_WEBSOCKET

LUA_RESTY_TPL=2.0
curl -sSL https://github.com/bungle/lua-resty-template/archive/v$LUA_RESTY_TPL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-template-$LUA_RESTY_TPL/lib/* .
rm -rf lua-resty-template-$LUA_RESTY_TPL

LUA_RESTY_MYSQL=0.23
curl -sSL https://github.com/openresty/lua-resty-mysql/archive/v$LUA_RESTY_MYSQL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-mysql-$LUA_RESTY_MYSQL/lib/* .
rm -rf lua-resty-mysql-$LUA_RESTY_MYSQL

LUA_RESTY_REDIS=0.29
curl -sSL https://github.com/openresty/lua-resty-redis/archive/v$LUA_RESTY_REDIS.tar.gz | tar zxf -
/bin/cp -rf lua-resty-redis-$LUA_RESTY_REDIS/lib/* .
rm -rf lua-resty-redis-$LUA_RESTY_REDIS

LUA_PGMOON=1.11.0
curl -sSL https://github.com/leafo/pgmoon/archive/v$LUA_PGMOON.tar.gz | tar zxf -
/bin/cp -rf pgmoon-$LUA_PGMOON/pgmoon .
rm -rf pgmoon-$LUA_PGMOON

LUA_PROTOBUF=0.3.2
curl -sSL https://github.com/starwing/lua-protobuf/archive/$LUA_PROTOBUF.tar.gz | tar zxf -
cd lua-protobuf-$LUA_PROTOBUF && gcc -O2 -shared -fPIC -I /usr/local/include/luajit-2.1 pb.c -o ../pb.so && /bin/cp -rf protoc.lua ../ && cd ..
rm -rf lua-protobuf-$LUA_PROTOBUF

LUA_RESTY_GRPC_GW=1.2.4
curl -sSL https://github.com/ysugimoto/lua-resty-grpc-gateway/archive/v$LUA_RESTY_GRPC_GW.tar.gz | tar zxf -
/bin/cp -rf lua-resty-grpc-gateway-$LUA_RESTY_GRPC_GW/grpc-gateway .
rm -rf lua-resty-grpc-gateway-$LUA_RESTY_GRPC_GW

# cjson
LUA_CJSON=2.1.0.8
curl -sSL https://github.com/openresty/lua-cjson/archive/$LUA_CJSON.tar.gz | tar zxf -
LUA_INCLUDE_DIR=/usr/local/include/luajit-2.1 make -C lua-cjson-$LUA_CJSON
mv -f lua-cjson-$LUA_CJSON/cjson.so .
rm -rf lua-cjson-$LUA_CJSON

# yaml
LIB_YAML=0.2.5
curl -sSL http://pyyaml.org/download/libyaml/yaml-$LIB_YAML.tar.gz | tar zxf -
cd yaml-$LIB_YAML && ./configure && make && make install && cd ..
rm -rf yaml-$LIB_YAML

LYAML=6.2.7
curl -sSL https://github.com/gvvaughan/lyaml/archive/v$LYAML.tar.gz | tar zxf -
cd lyaml-$LYAML && build-aux/luke LYAML_DIR=./target LUA_INCDIR=/usr/local/include/luajit-2.1 && build-aux/luke PREFIX=./target install && cd ..
mv lyaml-$LYAML/target/{lib/lua/5.1/yaml.so,share/lua/5.1/lyaml} .
rm -rf lyaml-$LYAML

mkdir -p /var/cache/nginx/client_temp
mkdir -p /etc/nginx/conf.d

# 开机自启动
cat > /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65535
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
Restart=always
RestartSec=5
StartLimitInterval=0
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# cert gen
mkdir -p /etc/nginx/conf.d /etc/nginx/cert
/usr/local/bin/openssl dhparam -out /etc/nginx/dhparam.pem 1024
/usr/local/bin/openssl req \
-x509 \
-nodes \
-days 36500 \
-newkey rsa:2048 \
-sha256 \
-keyout /etc/nginx/default.key \
-out /etc/nginx/default.crt \
-extensions 'v3_req' \
-config <( \
  echo '[req]'; \
  echo 'distinguished_name = req_distinguished_name'; \
  echo 'x509_extensions = v3_req'; \
  echo 'prompt = no'; \
  echo '[req_distinguished_name]'; \
  echo 'C = HJ'; \
  echo 'OU = IT'; \
  echo 'CN = hijack.local'; \
  echo '[v3_req]'; \
  echo 'keyUsage = digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment'; \
  echo 'extendedKeyUsage = serverAuth,clientAuth'; \
  echo 'subjectAltName = @alt_names'; \
  echo '[alt_names]'; \
  echo 'DNS.1 = hijack.local')

# dynamic modules usage in nginx.conf
# load_module "modules/xxxx.so"

cat > /etc/nginx/nginx.conf <<EOF
user root;
worker_processes auto;
worker_rlimit_nofile 65535;

#load_module "modules/ngx_http_waf_module.so"
#load_module "modules/ngx_http_echo_module.so";
#load_module "modules/ngx_http_flv_live_module.so";
#load_module "modules/ngx_http_geoip_module.so";
#load_module "modules/ngx_http_headers_more_filter_module.so";
#load_module "modules/ngx_http_image_filter_module.so";
#load_module "modules/ngx_http_srcache_filter_module.so";
#load_module "modules/ngx_http_subs_filter_module.so";
#load_module "modules/ngx_http_ts_module.so";
#load_module "modules/ngx_http_xslt_filter_module.so";

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;

events {
    multi_accept       on;
    worker_connections 65535;
}

http {
    charset utf-8;

    lua_package_path  "/etc/nginx/lualib/?.lua;/etc/nginx/lualib/?/init.lua;;";
    lua_package_cpath "/etc/nginx/lualib/?.so;;";

    # MIME
    include      mime.types;
    default_type application/octet-stream;

    # logging
    log_format main '\$request_id \$remote_addr [\$time_local] \$ssl_protocol/\$ssl_cipher "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_host" '
                         '\$http_user_agent \$http_x_forwarded_for \$request_time \$upstream_response_time \$upstream_addr \$upstream_status';

    access_log /var/log/nginx/access.log main;

    sendfile      on;
    tcp_nodelay   on;
    tcp_nopush    on;
    server_tokens off;
    keepalive_timeout 65;
    reset_timedout_connection on;

    gzip  on;
    gzip_vary on;
    gzip_disable "MSIE [1-6].";
    gzip_proxied any;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript;

    brotli            on;
    brotli_comp_level 6;
    brotli_buffers    16 8k;
    brotli_min_length 20;
    brotli_types      *;

    # SSL
    ssl_session_timeout 1d;
    ssl_session_cache   builtin:1000 shared:SSL:50m;
    ssl_session_tickets off;
    # Diffie-Hellman parameter for DHE ciphersuites
    ssl_dhparam   dhparam.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers   TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers off;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_early_data on;
    resolver 8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 valid=60s;
    resolver_timeout 5s;

    server {
        listen      80 default;
        server_name _;
        return 444;
    }

    server {
        listen    443 default_server ssl http2 fastopen=512 backlog=4096 reuseport so_keepalive=120s:60s:10;
        server_name _;
        ssl_stapling off;
        ssl_certificate default.crt;
        ssl_certificate_key default.key;
        return 444;
    }

    server {
        listen 127.0.0.1:80;
        server_name 127.0.0.1;
        location /nginx_status {
            access_log off;
            stub_status on;
            allow 127.0.0.1;
            deny all;
        }
    }

    include /etc/nginx/conf.d/*.conf;
    # proxy_cache_path /var/www/ngx_cache levels=1:2 keys_zone=ngx_cache:10m max_size=8g inactive=168h use_temp_path=off;
}

stream {
    log_format stream '\$remote_addr [\$time_local] '
                 '\$protocol $status \$bytes_sent \$bytes_received '
                 '\$session_time "\$upstream_addr" '
                 '"\$upstream_bytes_sent" "\$upstream_bytes_received" "\$upstream_connect_time"';

    access_log /var/log/nginx/stream.log stream;
    open_log_file_cache off;

    include /etc/nginx/conf.d/*.stream;
}
EOF


# log forward
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
