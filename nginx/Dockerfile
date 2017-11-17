FROM alpine

LABEL maintainer="sdrzlyz@gmail.com"

ENV NGINX_VERSION=1.13.6 \
    SOURCE_DIR=/tmp

RUN build_pkgs="build-base git gperf icu-dev libjpeg-turbo-dev linux-headers openssl-dev pcre-dev tzdata wget zlib-dev" && \
    runtime_pkgs="ca-certificates icu icu-libs libuuid libjpeg-turbo openssl pcre zlib" && \
    apk add --no-cache --update-cache ${build_pkgs} ${runtime_pkgs} && \
    cd ${SOURCE_DIR}  && \
    git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module && \
    git clone git://github.com/cuber/ngx_http_google_filter_module && \
    wget -O- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zxv && \
    cd ${SOURCE_DIR}/nginx-${NGINX_VERSION} && \
    ./configure \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/local/sbin/nginx \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-ipv6 \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-file-aio \
    --add-module=${SOURCE_DIR}/ngx_http_substitutions_filter_module \
    --add-module=${SOURCE_DIR}/ngx_http_google_filter_module && \
    make && make install && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && \
    rm -rf /tmp/* && \
    apk del ${build_pkgs} && \
    rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]
VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]