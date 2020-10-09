yum install -y which patch libxml2-devel libxslt-devel gd-devel GeoIP GeoIP-devel GeoIP-data

NGINXVER=1.18.0
NGINXNJS=0.4.4
NGINXDIR=/opt/nginx-$NGINXVER
NGINXNDK=0.3.1
NGINXLUA=0.10.17

mkdir -p $NGINXDIR/module && cd $NGINXDIR/module

rm -rf ngx_brotli
git clone https://github.com/google/ngx_brotli
cd ngx_brotli
git submodule update --init
cd ..

git clone -b $NGINXNJS https://github.com/nginx/njs

curl -sSL https://github.com/simplresty/ngx_devel_kit/archive/v$NGINXNDK.tar.gz | tar zxf -
curl -sSL https://github.com/openresty/lua-nginx-module/archive/v$NGINXLUA.tar.gz | tar zxf -


# dynamic modules
rm -rf $NGINXDIR/module/dynamic
mkdir -p $NGINXDIR/module/dynamic
cd $NGINXDIR/module/dynamic
git clone https://github.com/winshining/nginx-http-flv-module
git clone https://github.com/arut/nginx-ts-module
git clone https://github.com/openresty/echo-nginx-module
git clone https://github.com/openresty/headers-more-nginx-module
git clone https://github.com/openresty/srcache-nginx-module
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module

cd $NGINXDIR
curl -sSL https://nginx.org/download/nginx-$NGINXVER.tar.gz | tar zxf - -C . --strip-components 1 && rm -rf nginx.tgz

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.1

./configure \
    --with-cc-opt="-I/usr/local/openssl/include" \
    --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB -ljemalloc" \
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
    --add-dynamic-module=./module/dynamic/nginx-http-flv-module \
    --add-dynamic-module=./module/dynamic/nginx-ts-module \
    --add-dynamic-module=./module/dynamic/echo-nginx-module \
    --add-dynamic-module=./module/dynamic/headers-more-nginx-module \
    --add-dynamic-module=./module/dynamic/srcache-nginx-module \
    --add-dynamic-module=./module/dynamic/ngx_http_substitutions_filter_module

make -j$(nproc)
# make -j$(nproc) -f objs/Makefile modules

make install

# delete old modules
# rm -f /etc/nginx/modules/*.so.old

# dynamic modules in nginx.conf
# load_module "modules/xxxx.so"

# https://github.com/bungle/awesome-resty

# lualib module
mkdir -p /etc/nginx/lualib
cd /etc/nginx/lualib

LUACORE=0.1.19
curl -sSL https://github.com/openresty/lua-resty-core/archive/v$LUACORE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-core-$LUACORE/lib/* .
rm -rf lua-resty-core-$LUACORE

LUACACHE=0.10
curl -sSL https://github.com/openresty/lua-resty-lrucache/archive/v$LUACACHE.tar.gz | tar zxf -
/bin/cp -rf lua-resty-lrucache-$LUACACHE/lib/* .
rm -rf lua-resty-lrucache-$LUACACHE

LUAWEBSOCKET=0.07
curl -sSL https://github.com/openresty/lua-resty-websocket/archive/v$LUAWEBSOCKET.tar.gz | tar zxf -
/bin/cp -rf lua-resty-websocket-$LUAWEBSOCKET/lib/* .
rm -rf lua-resty-websocket-$LUAWEBSOCKET

LUARESTYTPL=2.0
curl -sSL https://github.com/bungle/lua-resty-template/archive/v$LUARESTYTPL.tar.gz | tar zxf -
/bin/cp -rf lua-resty-template-$LUARESTYTPL/lib/* .
rm -rf lua-resty-template-$LUARESTYTPL

# cjson
LUACJSON=2.1.0.8
curl -sSL https://github.com/openresty/lua-cjson/archive/$LUACJSON.tar.gz | tar zxf -
LUA_INCLUDE_DIR=/usr/local/include/luajit-2.1 make -C lua-cjson-$LUACJSON
mv -f lua-cjson-$LUACJSON/cjson.so .
rm -rf lua-cjson-$LUACJSON

# 开机自启动
mkdir -p /var/cache/nginx/client_temp
mkdir -p /etc/nginx/conf.d

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

cat > /etc/nginx/nginx.conf <<EOF
user root;
worker_processes auto;
worker_rlimit_nofile 65535;

#load_module "modules/ngx_http_echo_module.so";
#load_module "modules/ngx_http_flv_live_module.so";
#load_module "modules/ngx_http_geoip_module.so";
#load_module "modules/ngx_http_srcache_filter_module.so";
#load_module "modules/ngx_http_subs_filter_module.so";
#load_module "modules/ngx_http_ts_module.so";

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

    lua_package_path  "/etc/nginx/lualib/?.lua;;";
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
    ssl_dhparam   /etc/nginx/dhparam.pem;
    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers   TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
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

/usr/local/openssl/bin/openssl dhparam -out /etc/nginx/dhparam.pem 1024

# log forward
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
