#!/usr/bin/env bash

# https://www.nginx.com/blog/our-roadmap-quic-http-3-support-nginx/

set -e

source scl_source enable devtoolset-9 || true

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y \
    which patch \
    automake libtool `# ModSecurity` \
    gd-devel `# http_image_filter_module` \
    libxml2-devel libxslt-devel `# http_xslt_module`

NGINXVER=${1:-1.20.2}
NGINXNJS=0.6.2
NGINXDIR=/opt/nginx-$NGINXVER
NGINXNDK=0.3.1
NGINXLUA=0.10.20
NGINXSTREAMLUA=0.0.10

# nginx-quic
git clone https://github.com/VKCOM/nginx-quic.git $NGINXDIR
cd $NGINXDIR
curl -sSL https://raw.githubusercontent.com/kn007/patch/master/Enable_BoringSSL_OCSP.patch > Enable_BoringSSL_OCSP.patch
patch -p1 < Enable_BoringSSL_OCSP.patch


mkdir -p $NGINXDIR/module && cd $NGINXDIR/module

rm -rf ngx_brotli
git clone https://github.com/google/ngx_brotli
cd ngx_brotli
git submodule update --init
cd ..

# https://github.com/nginx/njs/tags, 0.7.x has unsupported tls
git clone -b $NGINXNJS https://github.com/nginx/njs

# https://github.com/vision5/ngx_devel_kit/tags
curl -sSL https://github.com/simplresty/ngx_devel_kit/archive/v$NGINXNDK.tar.gz | tar zxf -

# https://github.com/openresty/lua-nginx-module/tags
curl -sSL https://github.com/openresty/lua-nginx-module/archive/v$NGINXLUA.tar.gz | tar zxf -

# https://github.com/openresty/stream-lua-nginx-module/tags
curl -sSL https://github.com/openresty/stream-lua-nginx-module/archive/v$NGINXSTREAMLUA.tar.gz | tar zxf -

# https://github.com/pingostack/pingos
# replacement of https://github.com/winshining/nginx-http-flv-module
git clone https://github.com/pingostack/pingos.git
mv pingos/modules/* .

# dynamic modules
rm -rf $NGINXDIR/module/dynamic
mkdir -p $NGINXDIR/module/dynamic
cd $NGINXDIR/module/dynamic

# waf
curl -sSL https://github.com/maxmind/libmaxminddb/releases/download/1.6.0/libmaxminddb-1.6.0.tar.gz | tar zxf - 
cd libmaxminddb-1.6.0
./configure --prefix=/usr/local
make -j$(nproc) && make install
cd ..

# https://github.com/SpiderLabs/ModSecurity/tags
git clone -b v3.0.6 --recursive --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
./build.sh && ./configure --prefix=/usr/local --enable-examples=no
make -j$(nproc) && make install
cd ..

# https://github.com/SpiderLabs/ModSecurity-nginx/tags
git clone -b v1.0.2 --depth=1 --recursive --single-branch https://github.com/SpiderLabs/ModSecurity-nginx
# waf

# pagespeed
git clone -b v1.13.35.2-stable --depth 1 --quiet https://github.com/apache/incubator-pagespeed-ngx
curl -sSL https://dl.google.com/dl/page-speed/psol/1.13.35.2-x64.tar.gz | tar -xzf - -C ./incubator-pagespeed-ngx/

git clone --depth 1 --quiet -b 3.3 https://github.com/leev/ngx_http_geoip2_module
git clone --depth 1 --quiet -b v0.62 https://github.com/openresty/echo-nginx-module
git clone --depth 1 --quiet -b v0.33 https://github.com/openresty/headers-more-nginx-module
git clone --depth 1 --quiet -b v0.32 https://github.com/openresty/srcache-nginx-module
git clone --depth 1 --quiet -b v0.5.2 https://github.com/aperezdc/ngx-fancyindex
git clone --depth 1 --quiet https://github.com/vozlt/nginx-module-vts
git clone --depth 1 --quiet https://github.com/yaoweibin/ngx_http_substitutions_filter_module

cd $NGINXDIR
export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1
./auto/configure \
    --build=nginx-quic \
    --with-cc-opt="-DTCP_FASTOPEN=23 -Wno-error" \
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
    --with-compat \
    --with-http_dav_module \
    --with-http_flv_module \
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
    --with-http_v3_module \
    --with-http_quic_module \
    --with-stream_quic_module \
    --with-http_xslt_module=dynamic \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre-jit \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --add-module=./module/lua-nginx-module-$NGINXLUA \
    --add-module=./module/nginx-client-module \
    --add-module=./module/nginx-multiport-module \
    --add-module=./module/nginx-rtmp-module \
    --add-module=./module/nginx-toolkit-module \
    --add-module=./module/ngx_brotli \
    --add-module=./module/ngx_devel_kit-$NGINXNDK \
    --add-module=./module/njs/nginx \
    --add-module=./module/stream-lua-nginx-module-$NGINXSTREAMLUA \
    --add-dynamic-module=./module/dynamic/echo-nginx-module \
    --add-dynamic-module=./module/dynamic/headers-more-nginx-module \
    --add-dynamic-module=./module/dynamic/incubator-pagespeed-ngx \
    --add-dynamic-module=./module/dynamic/ModSecurity-nginx \
    --add-dynamic-module=./module/dynamic/nginx-module-vts \
    --add-dynamic-module=./module/dynamic/ngx-fancyindex \
    --add-dynamic-module=./module/dynamic/ngx_http_geoip2_module \
    --add-dynamic-module=./module/dynamic/ngx_http_substitutions_filter_module \
    --add-dynamic-module=./module/dynamic/srcache-nginx-module

make -j$(nproc)
# make -j$(nproc) -f objs/Makefile modules

make install

# delete old modules
# rm -f /etc/nginx/modules/*.so.old || true

mkdir -p /var/cache/nginx/client_temp /var/log/nginx /etc/nginx/conf.d /etc/nginx/lualib

# lualib module
# https://github.com/bungle/awesome-resty
cd /etc/nginx/lualib

# https://github.com/openresty/lua-resty-core/tags
LUA_RESTY_CORE=0.1.22
curl -sSL https://github.com/openresty/lua-resty-core/archive/v$LUA_RESTY_CORE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-core-$LUA_RESTY_CORE/lib/* .
rm -rf lua-resty-core-$LUA_RESTY_CORE

# https://github.com/openresty/lua-resty-lock/tags
LUA_RESTY_LOCK=0.08
curl -sSL https://github.com/openresty/lua-resty-lock/archive/v$LUA_RESTY_LOCK.tar.gz | tar zxf -
/bin/cp -rf lua-resty-lock-$LUA_RESTY_LOCK/lib/* .
rm -rf lua-resty-lock-$LUA_RESTY_LOCK

# https://github.com/openresty/lua-resty-lrucache/tags
LUA_RESTY_LRUCACHE=0.11
curl -sSL https://github.com/openresty/lua-resty-lrucache/archive/v$LUA_RESTY_LRUCACHE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-lrucache-$LUA_RESTY_LRUCACHE/lib/* .
rm -rf lua-resty-lrucache-$LUA_RESTY_LRUCACHE

# https://github.com/openresty/lua-resty-mysql/tags
LUA_RESTY_MYSQL=0.24
curl -sSL https://github.com/openresty/lua-resty-mysql/archive/v$LUA_RESTY_MYSQL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-mysql-$LUA_RESTY_MYSQL/lib/* .
rm -rf lua-resty-mysql-$LUA_RESTY_MYSQL

# https://github.com/openresty/lua-resty-redis/tags
LUA_RESTY_REDIS=0.29
curl -sSL https://github.com/openresty/lua-resty-redis/archive/v$LUA_RESTY_REDIS.tar.gz | tar zxf -
/bin/cp -rf lua-resty-redis-$LUA_RESTY_REDIS/lib/* .
rm -rf lua-resty-redis-$LUA_RESTY_REDIS

# https://github.com/openresty/lua-resty-string/tags
LUA_RESTY_STRING=0.15
curl -sSL https://github.com/openresty/lua-resty-string/archive/v$LUA_RESTY_STRING.tar.gz | tar zxf -
/bin/cp -rf lua-resty-string-$LUA_RESTY_STRING/lib/* .
rm -rf lua-resty-string-$LUA_RESTY_STRING

# https://github.com/openresty/lua-resty-upload/tags
LUA_RESTY_UPLOAD=0.10
curl -sSL https://github.com/openresty/lua-resty-upload/archive/v$LUA_RESTY_UPLOAD.tar.gz | tar zxf -
/bin/cp -rf lua-resty-upload-$LUA_RESTY_UPLOAD/lib/* .
rm -rf lua-resty-upload-$LUA_RESTY_UPLOAD

# https://github.com/openresty/lua-resty-upstream-healthcheck/tags
LUA_RESTY_UPSTREAM_HEALTHCHECK=0.06
curl -sSL https://github.com/openresty/lua-resty-upstream-healthcheck/archive/v$LUA_RESTY_UPSTREAM_HEALTHCHECK.tar.gz | tar zxf -
/bin/cp -rf lua-resty-upstream-healthcheck-$LUA_RESTY_UPSTREAM_HEALTHCHECK/lib/* .
rm -rf lua-resty-upstream-healthcheck-$LUA_RESTY_UPSTREAM_HEALTHCHECK

# https://github.com/openresty/lua-resty-websocket/tags
LUA_RESTY_WEBSOCKET=0.08
curl -sSL https://github.com/openresty/lua-resty-websocket/archive/v$LUA_RESTY_WEBSOCKET.tar.gz | tar zxf -
/bin/cp -rf lua-resty-websocket-$LUA_RESTY_WEBSOCKET/lib/* .
rm -rf lua-resty-websocket-$LUA_RESTY_WEBSOCKET

# https://github.com/openresty/lua-cjson/tags
LUA_CJSON=2.1.0.8
curl -sSL https://github.com/openresty/lua-cjson/archive/$LUA_CJSON.tar.gz | tar zxf -
LUA_INCLUDE_DIR=/usr/local/include/luajit-2.1 make -C lua-cjson-$LUA_CJSON
mv -f lua-cjson-$LUA_CJSON/cjson.so .
rm -rf lua-cjson-$LUA_CJSON

# https://github.com/ledgetech/lua-resty-http/tags
LUA_RESTY_HTTP=0.16.1
curl -sSL https://github.com/ledgetech/lua-resty-http/archive/v$LUA_RESTY_HTTP.tar.gz | tar zxf -
/bin/cp -rf lua-resty-http-$LUA_RESTY_HTTP/lib/* .
rm -rf lua-resty-http-$LUA_RESTY_HTTP

# https://github.com/fffonion/lua-resty-openssl/tags
LUA_RESTY_OPENSSL=0.8.8
curl -sSL https://github.com/fffonion/lua-resty-openssl/archive/$LUA_RESTY_OPENSSL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-openssl-$LUA_RESTY_OPENSSL/lib/* .
rm -rf lua-resty-openssl-$LUA_RESTY_OPENSSL

# https://github.com/fffonion/lua-resty-acme/tags
LUA_RESTY_ACME=0.8.0
curl -sSL https://github.com/fffonion/lua-resty-acme/archive/$LUA_RESTY_ACME.tar.gz | tar zxf -
/bin/cp -rf lua-resty-acme-$LUA_RESTY_ACME/lib/* .
rm -rf lua-resty-acme-$LUA_RESTY_ACME

# https://github.com/thibaultcha/lua-resty-mlcache/tags
LUA_RESTY_MLCACHE=2.5.0
curl -sSL https://github.com/thibaultcha/lua-resty-mlcache/archive/$LUA_RESTY_MLCACHE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-mlcache-$LUA_RESTY_MLCACHE/lib/* .
rm -rf lua-resty-mlcache-$LUA_RESTY_MLCACHE

# https://github.com/bungle/lua-resty-template/tags
LUA_RESTY_TPL=2.0
curl -sSL https://github.com/bungle/lua-resty-template/archive/v$LUA_RESTY_TPL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-template-$LUA_RESTY_TPL/lib/* .
rm -rf lua-resty-template-$LUA_RESTY_TPL

# https://github.com/leafo/pgmoon/tags
LUA_PGMOON=1.14.0
curl -sSL https://github.com/leafo/pgmoon/archive/v$LUA_PGMOON.tar.gz | tar zxf -
/bin/cp -rf pgmoon-$LUA_PGMOON/pgmoon .
rm -rf pgmoon-$LUA_PGMOON

# https://github.com/starwing/lua-protobuf/tags
LUA_PROTOBUF=master
curl -sSL https://github.com/starwing/lua-protobuf/archive/$LUA_PROTOBUF.tar.gz | tar zxf -
cd lua-protobuf-$LUA_PROTOBUF && gcc -O2 -shared -fPIC -I /usr/local/include/luajit-2.1 pb.c -o ../pb.so && /bin/cp -rf protoc.lua ../ && cd ..
rm -rf lua-protobuf-$LUA_PROTOBUF

# https://github.com/ysugimoto/lua-resty-grpc-gateway/tags
# LUA_RESTY_GRPC_GW=1.2.4
# curl -sSL https://github.com/ysugimoto/lua-resty-grpc-gateway/archive/v$LUA_RESTY_GRPC_GW.tar.gz | tar zxf -
# /bin/cp -rf lua-resty-grpc-gateway-$LUA_RESTY_GRPC_GW/grpc-gateway .
# rm -rf lua-resty-grpc-gateway-$LUA_RESTY_GRPC_GW

# kong https://github.com/Kong/kong
## kong.lua_pack
LUA_PACK=2.0.0
curl -sSL https://github.com/Kong/lua-pack/archive/$LUA_PACK.tar.gz | tar zxf -
gcc -O2 -shared -fPIC  -I/usr/local/include/luajit-2.1 lua-pack-$LUA_PACK/lua_pack.c -o lua_pack.so
rm -rf lua-pack-$LUA_PACK

## kong.plugins.grpc-gateway
mkdir -p kong/{plugins,tools}
KONG=2.8.1
curl -sSL https://github.com/Kong/kong/archive/$KONG.tar.gz | tar zxf -
/bin/cp -rf kong-$KONG/kong/plugins/grpc-gateway kong/plugins/
/bin/cp -rf kong-$KONG/kong/tools/grpc.lua kong/tools/
rm -rf kong-$KONG

# https://pyyaml.org
LIB_YAML=0.2.5
curl -sSL http://pyyaml.org/download/libyaml/yaml-$LIB_YAML.tar.gz | tar zxf -
cd yaml-$LIB_YAML && ./configure && make && make install && cd ..
rm -rf yaml-$LIB_YAML

# https://github.com/gvvaughan/lyaml/tags
LYAML=6.2.7
curl -sSL https://github.com/gvvaughan/lyaml/archive/v$LYAML.tar.gz | tar zxf -
cd lyaml-$LYAML && build-aux/luke LYAML_DIR=./target LUA_INCDIR=/usr/local/include/luajit-2.1 && build-aux/luke PREFIX=./target install && cd ..
mv lyaml-$LYAML/target/{lib/lua/5.1/yaml.so,share/lua/5.1/lyaml} .
rm -rf lyaml-$LYAML


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
mkdir -p /etc/nginx/cert /etc/nginx/acme

# dynamic modules usage in nginx.conf
# load_module "modules/xxxx.so"

MODULE_LIST=""
for file in `ls /etc/nginx/modules/*.so`; do
  if [ -z "$MODULE_LIST" ]; then
    MODULE_LIST="#load_module \"$file\";"
  else
    MODULE_LIST="$MODULE_LIST
#load_module \"$file\";"
  fi
done

cat > /etc/nginx/nginx.conf <<EOF
user root;
worker_processes auto;
worker_rlimit_nofile 65535;

$MODULE_LIST

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;

events {
    use epoll;
    multi_accept on;
    worker_connections 65535;
    #multi_listen unix:/tmp/rtmp 1935;
}

rtmp {
    out_queue           4096;
    out_cork            8;
    max_streams         512;
    timeout             15s;
    drop_idle_publisher 15s;

    rtmp_auto_pull on;
    rtmp_auto_pull_port unix:/tmp/rtmp;

    include /etc/nginx/conf.d/*.rtmp;
}

stream {
    lua_package_path  "/etc/nginx/lualib/?.lua;/etc/nginx/lualib/?/init.lua;;";
    lua_package_cpath "/etc/nginx/lualib/?.so;;";

    log_format stream '\$remote_addr [\$time_local] '
                 '\$protocol $status \$bytes_sent \$bytes_received '
                 '\$session_time "\$upstream_addr" '
                 '"\$upstream_bytes_sent" "\$upstream_bytes_received" "\$upstream_connect_time"';

    access_log /var/log/nginx/stream.log stream;
    open_log_file_cache off;

    include /etc/nginx/conf.d/*.stream;
}

http {
    lua_package_path  "/etc/nginx/lualib/?.lua;/etc/nginx/lualib/?/init.lua;;";
    lua_package_cpath "/etc/nginx/lualib/?.so;;";

    charset utf-8;

    # MIME
    include      mime.types;
    types {
        #application/wasm wasm;
    }
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

    # 0-RTT
    ssl_early_data on;
    quic_retry on;
    quic_gso on;

    resolver 8.8.8.8 223.5.5.5 119.29.29.29 valid=60s ipv6=off;
    resolver_timeout 15s;

    lua_shared_dict acme 16m;
    # required to verify Let's Encrypt API
    lua_ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
    lua_ssl_verify_depth 2;

    init_by_lua_block {
        require("resty.acme.autossl").init({
            -- setting the following to true
            -- implies that you read and accepted https://letsencrypt.org/repository/
            tos_accepted = true,
            -- uncomment following for first time setup
            -- staging = true,
            -- uncomment following to enable RSA + ECC double cert
            domain_key_types = { "rsa", "ecc" },
            -- uncomment following to enable tls-alpn-01 challenge
            -- enabled_challenge_handlers = { "http-01", "tls-alpn-01" },
            account_key_path = "/etc/nginx/account.key",
            account_email = "sdrzlyz@gmail.com",
            -- domain_whitelist = { "example.com" },
            domain_whitelist_callback = function(domain, is_new_cert_needed)
                return true
            end,
            renew_check_interval = 24 * 3600,
            storage_adapter = "file",
            storage_config = {
                dir = "/etc/nginx/acme",
            },
        })
    }

    init_worker_by_lua_block {
        require("resty.acme.autossl").init_worker()
    }

    server {
        listen      80 default;
        server_name _;
        return 444;
    }

    server {
        listen    443 http3 quic reuseport;
        listen    443 default_server ssl http2 fastopen=512 backlog=4096 so_keepalive=120s:60s:10;
        server_name _;
        ssl_stapling off;
        ssl_certificate default.crt;
        ssl_certificate_key default.key;
        add_header alt-svc 'h3=":443"; ma=86400';
        return 444;
    }

    server {
        listen 80;
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
EOF

# static file copy
mkdir -p /etc/nginx/html/rtmp
\cp $NGINXDIR/module/pingos/resource/stat.xsl /etc/nginx/html/rtmp/stat.xsl

mkdir -p /etc/nginx/modsec
cat > /etc/nginx/modsec/main.conf <<EOF
Include "/etc/nginx/modsec/modsecurity.conf"
Include "/etc/nginx/modsec/coreruleset/crs-setup.conf"
Include "/etc/nginx/modsec/coreruleset/rules/*.conf"
EOF
\cp $NGINXDIR/module/dynamic/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
\cp $NGINXDIR/module/dynamic/ModSecurity/unicode.mapping /etc/nginx/modsec/unicode.mapping
git clone --depth=1 https://github.com/coreruleset/coreruleset /etc/nginx/modsec/coreruleset
mv /etc/nginx/modsec/coreruleset/crs-setup.conf.example /etc/nginx/modsec/coreruleset/crs-setup.conf
find /etc/nginx/modsec/coreruleset -mindepth 1 -maxdepth 1 -type f -not -path "*.conf" -delete
find /etc/nginx/modsec/coreruleset -mindepth 1 -maxdepth 1 -type d -not -name 'rules' | xargs rm -rf

touch /var/log/nginx/{access,stream,error}.log

# log forward
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stdout /var/log/nginx/stream.log
ln -sf /dev/stderr /var/log/nginx/error.log

# remove cache
yum remove -y devtoolset-9-* centos-release-scl scl-utils-build \
    make git patch automake libtool \
    pcre-devel zlib-devel gd-devel libxml2-devel libxslt-devel libmaxminddb-devel
yum clean all
rm -rf /opt/{lib-src,nginx-*} /tmp/*
