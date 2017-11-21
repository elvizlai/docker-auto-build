FROM alpine

LABEL maintainer="sdrzlyz@gmail.com"

ENV OPENRESTY_VERSION=1.13.6.1 \
    SOURCE_DIR=/tmp

RUN build_pkgs="build-base git curl gd-dev geoip-dev libxslt-dev perl-dev readline-dev gperf tzdata wget linux-headers icu-dev libjpeg-turbo-dev openssl-dev pcre-dev zlib-dev" && \
    runtime_pkgs="ca-certificates gd geoip libgcc libxslt icu icu-libs libuuid libjpeg-turbo openssl pcre zlib" && \
    apk add --no-cache --update-cache ${build_pkgs} ${runtime_pkgs} && \
    cd ${SOURCE_DIR}  && \
    git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module && \
    git clone git://github.com/cuber/ngx_http_google_filter_module && \
    wget -O- https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | tar -zx && \
    cd ${SOURCE_DIR}/openresty-${OPENRESTY_VERSION} && \
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
    --with-http_iconv_module \
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