#!/usr/bin/env bash

set -e

yum install -y \
    make git \
    pcre pcre-devel zlib zlib-devel \
    centos-release-scl scl-utils-build \
    bzip2 `# jemalloc` \
    unzip `# luarocks`

# systemd-devel scl-utils

yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++

source scl_source enable devtoolset-9 || true
# gcc -v

# ZLIB=zlib-1.2.12
# PCRE=pcre-8.45
JEMALLOC=5.2.1
LUAJIT=v2.1-20220411
LUAROCKS=3.8.0

mkdir -p /opt/lib-src && cd /opt/lib-src

# zlib http://zlib.net
# curl -sSL http://zlib.net/$ZLIB.tar.gz | tar zxf -
# cd $ZLIB
# ./configure --static
# make -j4 && make install && cd ..

# https://www.pcre.org/
# for ftp download is closed nowm, use morn mirror instead.
# check version `pcre-config --version`
# curl -sSL http://ftp.cs.stanford.edu/pub/exim/pcre/$PCRE.tar.gz | tar zxf -
# cd $PCRE
# ./configure --enable-utf8 --enable-jit
# make -j4 && make install && cd ..

# cmake
curl -sSL https://cmake.org/files/v3.22/cmake-3.22.0.tar.gz | tar zxf - -C /opt/lib-src
cd /opt/lib-src/cmake-3.*
./bootstrap --prefix=/usr/local -- -DCMAKE_USE_OPENSSL=OFF
make -j$(nproc) && make install && cd ..

# golang
curl -sSL https://golang.org/dl/go1.17.linux-amd64.tar.gz | tar zxf - -C /tmp
export PATH=/tmp/go/bin:$PATH

# rust
export CARGO_HOME=/tmp/cargo && export RUSTUP_HOME=/tmp/rustup && export PATH=$CARGO_HOME/bin:$PATH
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# boringssl
git clone -b fips-20210429 https://boringssl.googlesource.com/boringssl /opt/lib-src/boringssl
mkdir -p /opt/lib-src/boringssl/build && cd /opt/lib-src/boringssl/build
cmake -DFIPS=0 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 ..
make
cp */*.so /usr/local/lib/
cp -r ../include/openssl /usr/local/include/
cd /opt/lib-src

# jemalloc https://github.com/jemalloc/jemalloc
curl -sSL https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC/jemalloc-$JEMALLOC.tar.bz2 | tar xjf -
cd jemalloc-$JEMALLOC
./configure --prefix=/usr/local --libdir=/usr/local/lib
make -j4 && make install && cd ..

# lua-jit https://github.com/openresty/luajit2/tags
mkdir -p luajit2.1
curl -sSL https://github.com/openresty/luajit2/archive/$LUAJIT.tar.gz | tar zxf - -C luajit2.1 --strip-components 1
cd luajit2.1
make -j4 && make install && cd ..

# luarocks https://luarocks.org
curl -sSL http://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS.tar.gz | tar zxf -
cd luarocks-$LUAROCKS
./configure --lua-suffix=jit
make && make install && cd ..

# pl https://github.com/lunarmodules/Penlight
# it deps on luafilesystem https://github.com/keplerproject/luafilesystem
luarocks install penlight

# date https://github.com/Tieske/date
luarocks install date

# TODO optimize
if [ ! -f "/etc/ld.so.conf.d/usr_local_lib.conf" ];then
    touch /etc/ld.so.conf.d/usr_local_lib.conf
fi
if [ `grep -Fxq "/usr/local/lib" /etc/ld.so.conf.d/usr_local_lib.conf;echo $?` != "0" ];then
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/usr_local_lib.conf
fi
ldconfig -v

sed -i '/cargo/d' /root/.bash_profile /root/.bashrc
rm -rf /root/go
