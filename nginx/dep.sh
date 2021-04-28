#!/usr/bin/env bash

set -e

yum install -y make git bzip2 unzip systemd-devel \
    centos-release-scl scl-utils-build scl-utils

yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++

source scl_source enable devtoolset-9 || true

PCRE=pcre-8.44
ZLIB=zlib-1.2.11
OPENSSL=openssl-1.1.1k
JEMALLOC=5.2.1
LUAJIT=v2.1-20201229
LUAROCKS=3.6.0

mkdir -p /opt/lib-src && cd /opt/lib-src

# pcre `pcre-config --version`
curl -sSL https://ftp.pcre.org/pub/pcre/$PCRE.tar.gz | tar zxf -
cd $PCRE
./configure --enable-utf8 --enable-jit
make -j4 && make install && cd ..

# zlib
curl -sSL http://zlib.net/$ZLIB.tar.gz | tar zxf -
cd $ZLIB
./configure --static 
make -j4 && make install && cd ..

# openssl https://www.openssl.org/source
curl -sSL https://www.openssl.org/source/$OPENSSL.tar.gz | tar zxf -
cd $OPENSSL
./config --prefix=/usr/local --libdir=/usr/local/lib shared
make -j4 && make install && cd ..

# jemalloc https://github.com/jemalloc/jemalloc
curl -sSL https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC/jemalloc-$JEMALLOC.tar.bz2 | tar xjf -
cd jemalloc-$JEMALLOC
./configure --prefix=/usr/local --libdir=/usr/local/lib
make -j4 && make install && cd ..

# lua-jit https://github.com/openresty/luajit2
mkdir -p luajit2.1
curl -sSL https://github.com/openresty/luajit2/archive/$LUAJIT.tar.gz | tar zxf - -C luajit2.1 --strip-components 1
cd luajit2.1
make -j4 && make install && cd ..

# luarocks https://luarocks.org
curl -sSL http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS.tar.gz | tar zxf -
cd luarocks-$LUAROCKS
./configure
make && make install && cd ..

# TODO optimize
if [ ! -f "/etc/ld.so.conf.d/usr_local_lib.conf" ];then
    touch /etc/ld.so.conf.d/usr_local_lib.conf
fi
if [ `grep -Fxq "/usr/local/lib" /etc/ld.so.conf.d/usr_local_lib.conf;echo $?` != "0" ];then
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/usr_local_lib.conf
fi
ldconfig -v
