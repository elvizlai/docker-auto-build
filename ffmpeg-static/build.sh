#!/usr/bin/env bash

## ref
## https://github.com/jrottenberg/ffmpeg/blob/master/docker-images/3.4/centos7/Dockerfile
## https://github.com/markus-perl/ffmpeg-build-script/blob/master/build-ffmpeg
## https://github.com/zimbatm/ffmpeg-static/blob/master/build.sh

yum install -y make git bzip2 unzip systemd-devel \
    centos-release-scl scl-utils-build scl-utils
yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++
source scl_source enable devtoolset-9 || true

## 
yum install -y libgomp patch glibc-static libstdc++-static zlib-static expat-static


export FFMPEG_VERSION=3.4.8 \
AOM_VERSION=v1.0.0 \
FDKAAC_VERSION=0.1.5 \
FONTCONFIG_VERSION=2.12.4 \
FREETYPE_VERSION=2.5.5 \
FRIBIDI_VERSION=0.19.7 \
KVAZAAR_VERSION=2.0.0 \
LAME_VERSION=3.100 \
LIBASS_VERSION=0.13.7 \
LIBPTHREAD_STUBS_VERSION=0.4 \
LIBVIDSTAB_VERSION=1.1.0 \
LIBXCB_VERSION=1.13.1 \
XCBPROTO_VERSION=1.13 \
OGG_VERSION=1.3.2 \
OPENCOREAMR_VERSION=0.1.5 \
OPUS_VERSION=1.2 \
OPENJPEG_VERSION=2.1.2 \
THEORA_VERSION=1.1.1 \
VORBIS_VERSION=1.3.5 \
VPX_VERSION=1.8.0 \
WEBP_VERSION=1.0.2 \
X264_VERSION=20191217-2245-stable \
X265_VERSION=3.2.1 \
XAU_VERSION=1.0.9 \
XORG_MACROS_VERSION=1.19.2 \
XPROTO_VERSION=7.0.31 \
XVID_VERSION=1.3.4 \
LIBXML2_VERSION=2.9.10 \
LIBBLURAY_VERSION=1.1.2 \
LIBZMQ_VERSION=4.3.2 \
LIBSRT_VERSION=1.4.1 \
LIBARIBB24_VERSION=1.0.3 \
LIBPNG_VERSION=1.6.9 \
LIBVMAF_VERSION=2.1.1 \
SRC=/usr/local


export FREETYPE_SHA256SUM="5d03dd76c2171a7601e9ce10551d52d4471cf92cd205948e60289251daddffa8 freetype-2.5.5.tar.gz"
export FRIBIDI_SHA256SUM="3fc96fa9473bd31dcb5500bdf1aa78b337ba13eb8c301e7c28923fea982453a8 0.19.7.tar.gz"
export LIBASS_SHA256SUM="8fadf294bf701300d4605e6f1d92929304187fca4b8d8a47889315526adbafd7 0.13.7.tar.gz"
export LIBVIDSTAB_SHA256SUM="14d2a053e56edad4f397be0cb3ef8eb1ec3150404ce99a426c4eb641861dc0bb v1.1.0.tar.gz"
export OGG_SHA256SUM="e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692 libogg-1.3.2.tar.gz"
export OPUS_SHA256SUM="77db45a87b51578fbc49555ef1b10926179861d854eb2613207dc79d9ec0a9a9 opus-1.2.tar.gz"
export THEORA_SHA256SUM="40952956c47811928d1e7922cda3bc1f427eb75680c3c37249c91e949054916b libtheora-1.1.1.tar.gz"
export VORBIS_SHA256SUM="6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce libvorbis-1.3.5.tar.gz"
export XVID_SHA256SUM="4e9fd62728885855bc5007fe1be58df42e5e274497591fec37249e1052ae316f xvidcore-1.3.4.tar.gz"
export LIBXML2_SHA256SUM="f07dab13bf42d2b8db80620cce7419b3b87827cc937c8bb20fe13b8571ee9501  libxml2-v2.9.10.tar.gz"
export LIBBLURAY_SHA256SUM="a3dd452239b100dc9da0d01b30e1692693e2a332a7d29917bf84bb10ea7c0b42 libbluray-1.1.2.tar.bz2"
export LIBZMQ_SHA256SUM="02ecc88466ae38cf2c8d79f09cfd2675ba299a439680b64ade733e26a349edeb v4.3.2.tar.gz"
export LIBARIBB24_SHA256SUM="f61560738926e57f9173510389634d8c06cabedfa857db4b28fb7704707ff128 v1.0.3.tar.gz"
export LIBVMAF_SHA256SUM="e7fc00ae1322a7eccfcf6d4f1cdf9c67eec8058709887c8c6c3795c617326f77 v2.1.1.tar.gz"


export LD_LIBRARY_PATH=/opt/ffmpeg/lib
export MAKEFLAGS="-j2"
export PKG_CONFIG_PATH="/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig"
export PREFIX=/opt/ffmpeg
export LD_LIBRARY_PATH="/opt/ffmpeg/lib:/opt/ffmpeg/lib64"


buildDeps="autoconf \
           automake \
           bzip2 \
           cmake3 \
           diffutils \
           expat-devel \
           file \
           gcc \
           gcc-c++ \
           git \
           gperf \
           libtool \
           make \
           perl \
           python3 \
           openssl-devel \
           tar \
           yasm \
           which \
           zlib-devel" && \
echo "${SRC}/lib" > /etc/ld.so.conf.d/libc.conf && \
yum --enablerepo=extras install -y epel-release && \
yum --enablerepo=epel install -y ${buildDeps} && \
alternatives --install /usr/bin/cmake cmake /usr/bin/cmake3 0 && \
# Install the tools required to build nasm 2.14.02 \
nasmDeps="asciidoc \
                perl-Font-TTF \
                perl-Sort-Versions \
                xmlto" && \
yum --enablerepo=epel install -y ${nasmDeps} && \
# Compile and install nasm 2.14.02 \
DIR=/tmp/nasm && \
mkdir -p ${DIR} && \
curl -LSs https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.gz | \
tar xzC ${DIR} --strip-components=1 && \
pushd ${DIR} && \
./configure --host=x86_64-redhat-linux-gnu \
                --build=x86_64-redhat-linux-gnu \
                --prefix=/usr/local \
                --exec-prefix=/usr/local \
                --bindir=/usr/local/bin \
                --sbindir=/usr/local/sbin \
                --sysconfdir=/usr/local/etc \
                --datadir=/usr/local/share \
                --includedir=/usr/local/include \
                --libdir=/usr/local/lib \
                --libexecdir=/usr/local/libexec \
                --enable-sections && \
make all && \
make install && \
make install_rdf && \
popd && rm -rf ${DIR} && \
alternatives --install /usr/bin/nasm nasm /usr/local/bin/nasm 0 && \
# Now that we have a modern nasm build and available, we can undo the last \
# yum transaction as none of those packages are required for the rest of the build \
yum history undo $(yum history info | grep 'Transaction ID' | awk -F: '{print$2}' | tr -d ' ') -y && \
yum autoremove -y


## zlib
# DIR=/tmp/zlib && \
# mkdir -p ${DIR} && \
# cd ${DIR} && \
# curl -sL https://www.zlib.net/zlib-1.2.11.tar.gz | \
# tar -zx --strip-components=1 && \
# ./configure --prefix="${PREFIX}" --static -fPIC && \
# make && \
# make install && \
# rm -rf ${DIR}

## openssl
DIR=/tmp/openssl && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://www.openssl.org/source/openssl-1.1.1k.tar.gz | \
tar -zx --strip-components=1 && \
# ./config --prefix="${PREFIX}" --openssldir="${PREFIX}" --with-zlib-include="${PREFIX}"/include/ --with-zlib-lib="${PREFIX}"/lib no-shared zlib && \
./config --prefix="${PREFIX}" --openssldir="${PREFIX}" no-shared zlib && \
make && \
make install_sw && \
rm -rf ${DIR}

## libvmaf https://github.com/Netflix/vmaf
if which meson || false; then \
        echo "Building VMAF." && \
        DIR=/tmp/vmaf && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/Netflix/vmaf/archive/v${LIBVMAF_VERSION}.tar.gz && \
        tar -xz --strip-components=1 -f v${LIBVMAF_VERSION}.tar.gz && \
        cd /tmp/vmaf/libvmaf && \
        meson build --buildtype release --prefix=${PREFIX} && \
        ninja -vC build && \
        ninja -vC build install && \
        mkdir -p ${PREFIX}/share/model/ && \
        cp -r /tmp/vmaf/model/* ${PREFIX}/share/model/ && \
        rm -rf ${DIR}; \
else \
        echo "VMAF skipped."; \
fi

## opencore-amr https://sourceforge.net/projects/opencore-amr/
DIR=/tmp/opencore-amr && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://versaweb.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR_VERSION}.tar.gz | \
tar -zx --strip-components=1 && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## x264 http://www.videolan.org/developers/x264.html
DIR=/tmp/x264 && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
tar -jx --strip-components=1 && \
./configure --prefix="${PREFIX}" --enable-static --enable-pic --disable-cli && \
make && \
make install && \
rm -rf ${DIR}

## x265 http://x265.org/
DIR=/tmp/x265 && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://download.videolan.org/pub/videolan/x265/x265_${X265_VERSION}.tar.gz  | \
tar -zx && \
cd x265_${X265_VERSION}/build/linux && \
# cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DENABLE_SHARED=OFF -DBUILD_SHARED_LIBS=OFF ../../source && \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF ../../source && \
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc && \
# sed -i "/-DEXTRA_LIB/ s/$/ -DCMAKE_INSTALL_PREFIX=\${PREFIX}/" multilib.sh && \
# sed -i "/^cmake/ s/$/ -DENABLE_CLI=OFF/" multilib.sh && \
# sed -i "/^cmake/ s/$/ -DENABLE_SHARED=OFF/" multilib.sh && \
# sed -i "/^cmake/ s/$/ -DBUILD_SHARED_LIBS=OFF/" multilib.sh && \
# ./multilib.sh && \
make && \
make install && \
rm -rf ${DIR}

## libogg https://www.xiph.org/ogg/
DIR=/tmp/ogg && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz && \
echo ${OGG_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f libogg-${OGG_VERSION}.tar.gz && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static  && \
make && \
make install && \
rm -rf ${DIR}

## libopus https://www.opus-codec.org/
DIR=/tmp/opus && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz && \
echo ${OPUS_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f opus-${OPUS_VERSION}.tar.gz && \
autoreconf -fiv && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libvorbis https://xiph.org/vorbis/
DIR=/tmp/vorbis && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz && \
echo ${VORBIS_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f libvorbis-${VORBIS_VERSION}.tar.gz && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static --disable-oggtest && \
make && \
make install && \
rm -rf ${DIR}

## libtheora http://www.theora.org/
DIR=/tmp/theora && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.gz && \
echo ${THEORA_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f libtheora-${THEORA_VERSION}.tar.gz && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static \
--disable-oggtest --disable-vorbistest --disable-examples --disable-asm --disable-spec && \
make && \
make install && \
rm -rf ${DIR}

## libvpx https://www.webmproject.org/code/
DIR=/tmp/vpx && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://codeload.github.com/webmproject/libvpx/tar.gz/v${VPX_VERSION} | \
tar -zx --strip-components=1 && \
./configure --prefix="${PREFIX}" --enable-vp8 --enable-vp9 --enable-vp9-highbitdepth --enable-pic --disable-shared --enable-static \
--disable-debug --disable-examples --disable-unit-tests --disable-docs --disable-install-bins  && \
make && \
make install && \
rm -rf ${DIR}

## libwebp https://developers.google.com/speed/webp/
DIR=/tmp/vebp && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz | \
tar -zx --strip-components=1 && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libmp3lame http://lame.sourceforge.net/
DIR=/tmp/lame && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://versaweb.dl.sourceforge.net/project/lame/lame/$(echo ${LAME_VERSION} | sed -e 's/[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)/\1.\2/')/lame-${LAME_VERSION}.tar.gz | \
tar -zx --strip-components=1 && \
./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" --disable-shared --enable-static --enable-nasm --disable-frontend && \
make && \
make install && \
rm -rf ${DIR}

## xvid https://www.xvid.com/
DIR=/tmp/xvid && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz && \
echo ${XVID_SHA256SUM} | sha256sum --check && \
tar -zx -f xvidcore-${XVID_VERSION}.tar.gz && \
cd xvidcore/build/generic && \
./configure --prefix="${PREFIX}" --bindir="${PREFIX}/bin" && \
make && \
make install && \
rm -rf ${DIR}

## fdk-aac https://github.com/mstorsjo/fdk-aac
DIR=/tmp/fdk-aac && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://github.com/mstorsjo/fdk-aac/archive/v${FDKAAC_VERSION}.tar.gz | \
tar -zx --strip-components=1 && \
autoreconf -fiv && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static --datadir="${DIR}" && \
make && \
make install && \
rm -rf ${DIR}

## openjpeg https://github.com/uclouvain/openjpeg
DIR=/tmp/openjpeg && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | \
tar -zx --strip-components=1 && \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBUILD_THIRDPARTY:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF && \
make && \
make install && \
rm -rf ${DIR}

## freetype https://www.freetype.org/
DIR=/tmp/freetype && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz && \
echo ${FREETYPE_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f freetype-${FREETYPE_VERSION}.tar.gz && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libvstab https://github.com/georgmartius/vid.stab
DIR=/tmp/vid.stab && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz && \
echo ${LIBVIDSTAB_SHA256SUM} | sha256sum --check &&  \
tar -zx --strip-components=1 -f v${LIBVIDSTAB_VERSION}.tar.gz && \
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBUILD_SHARED_LIBS=OFF -DUSE_OMP=OFF && \
make && \
make install && \
rm -rf ${DIR}

## fridibi https://www.fribidi.org/
DIR=/tmp/fribidi && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/fribidi/fribidi/archive/${FRIBIDI_VERSION}.tar.gz && \
echo ${FRIBIDI_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f ${FRIBIDI_VERSION}.tar.gz && \
# sed -i 's/^SUBDIRS =.*/SUBDIRS=gen.tab charset lib bin/' Makefile.am && \
./bootstrap --no-config --auto && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make -j1 && \
make install && \
rm -rf ${DIR}

## fontconfig https://www.freedesktop.org/wiki/Software/fontconfig/
DIR=/tmp/fontconfig && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.bz2 && \
tar -jx --strip-components=1 -f fontconfig-${FONTCONFIG_VERSION}.tar.bz2 && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libass https://github.com/libass/libass
DIR=/tmp/libass && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz && \
echo ${LIBASS_SHA256SUM} | sha256sum --check && \
tar -zx --strip-components=1 -f ${LIBASS_VERSION}.tar.gz && \
./autogen.sh && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## kvazaar https://github.com/ultravideo/kvazaar
DIR=/tmp/kvazaar && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f v${KVAZAAR_VERSION}.tar.gz && \
./autogen.sh && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## aom 
cd /tmp && \
DIR=/tmp/aom && \
git clone --branch ${AOM_VERSION} --depth 1 https://aomedia.googlesource.com/aom ${DIR} ; \
cd ${DIR} ; \
rm -rf CMakeCache.txt CMakeFiles ; \
mkdir -p ./aom_build ; \
cd ./aom_build ; \
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DENABLE_TESTS=0 -DCMAKE_INSTALL_LIBDIR=lib .. ; \
make ; \
make install ; \
rm -rf ${DIR}

## libxcb (and supporting libraries) for screen capture https://xcb.freedesktop.org/
DIR=/tmp/xorg-macros && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://www.x.org/archive//individual/util/util-macros-${XORG_MACROS_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f util-macros-${XORG_MACROS_VERSION}.tar.gz && \
./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

## xproto
DIR=/tmp/xproto && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://www.x.org/archive/individual/proto/xproto-${XPROTO_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f xproto-${XPROTO_VERSION}.tar.gz && \
./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

## libXau
DIR=/tmp/libXau && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://www.x.org/archive/individual/lib/libXau-${XAU_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f libXau-${XAU_VERSION}.tar.gz && \
./configure --srcdir=${DIR} --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

##
DIR=/tmp/libpthread-stubs && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://xcb.freedesktop.org/dist/libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.gz && \
./configure --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

##
DIR=/tmp/libxcb-proto && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://xcb.freedesktop.org/dist/xcb-proto-${XCBPROTO_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f xcb-proto-${XCBPROTO_VERSION}.tar.gz && \
ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
./configure --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

##
DIR=/tmp/libxcb && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://xcb.freedesktop.org/dist/libxcb-${LIBXCB_VERSION}.tar.gz && \
tar -zx --strip-components=1 -f libxcb-${LIBXCB_VERSION}.tar.gz && \
ACLOCAL_PATH="${PREFIX}/share/aclocal" ./autogen.sh && \
./configure --prefix="${PREFIX}" --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libxml2 - for libbluray
DIR=/tmp/libxml2 && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${LIBXML2_VERSION}/libxml2-v${LIBXML2_VERSION}.tar.gz && \
echo ${LIBXML2_SHA256SUM} | sha256sum --check && \
tar -xz --strip-components=1 -f libxml2-v${LIBXML2_VERSION}.tar.gz && \
./autogen.sh --prefix="${PREFIX}" --with-ftp=no --with-http=no --with-python=no && \
make && \
make install && \
rm -rf ${DIR}

## libbluray - Requires libxml, freetype, and fontconfig
DIR=/tmp/libbluray && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://download.videolan.org/pub/videolan/libbluray/${LIBBLURAY_VERSION}/libbluray-${LIBBLURAY_VERSION}.tar.bz2 && \
echo ${LIBBLURAY_SHA256SUM} | sha256sum --check && \
tar -jx --strip-components=1 -f libbluray-${LIBBLURAY_VERSION}.tar.bz2 && \
./configure --prefix="${PREFIX}" --disable-examples --disable-bdjava-jar --disable-shared --enable-static && \
make && \
make install && \
rm -rf ${DIR}

## libzmq https://github.com/zeromq/libzmq/
DIR=/tmp/libzmq && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/zeromq/libzmq/archive/v${LIBZMQ_VERSION}.tar.gz && \
echo ${LIBZMQ_SHA256SUM} | sha256sum --check && \
tar -xz --strip-components=1 -f v${LIBZMQ_VERSION}.tar.gz && \
./autogen.sh && \
./configure --prefix="${PREFIX}" && \
make && \
make install && \
rm -rf ${DIR}

## libsrt https://github.com/Haivision/srt
DIR=/tmp/srt && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/Haivision/srt/archive/v${LIBSRT_VERSION}.tar.gz && \
tar -xz --strip-components=1 -f v${LIBSRT_VERSION}.tar.gz && \
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_BINDIR=bin -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DENABLE_APPS=OFF -DUSE_STATIC_LIBSTDCXX=ON && \
make && \
make install && \
rm -rf ${DIR}

## libpng
DIR=/tmp/png && \
mkdir -p ${DIR} && \
cd ${DIR} && \
git clone https://git.code.sf.net/p/libpng/code ${DIR} -b v${LIBPNG_VERSION} --depth 1 && \
./autogen.sh && \
./configure --prefix="${PREFIX}" && \
make check && \
make install && \
rm -rf ${DIR}

## libaribb24
DIR=/tmp/b24 && \
mkdir -p ${DIR} && \
cd ${DIR} && \
curl -sLO https://github.com/nkoriyama/aribb24/archive/v${LIBARIBB24_VERSION}.tar.gz && \
echo ${LIBARIBB24_SHA256SUM} | sha256sum --check && \
tar -xz --strip-components=1 -f v${LIBARIBB24_VERSION}.tar.gz && \
autoreconf -fiv && \
./configure --prefix="${PREFIX}" CFLAGS="-I${PREFIX}/include -fPIC" && \
make && \
make install && \
rm -rf ${DIR}

## ffmpeg https://ffmpeg.org/
DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
curl -sLO https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
tar -jx --strip-components=1 -f ffmpeg-${FFMPEG_VERSION}.tar.bz2

## !patch: h265 flv
curl -sSL https://gist.githubusercontent.com/elvizlai/2331ca7ac68d960c5d7b7f3dce31b996/raw/ffmpeg_v3.3_flv_hevc.patch > ffmpeg_flv_hevc.patch
patch -p1 < ffmpeg_flv_hevc.patch

## x265
DIR=/tmp/ffmpeg && mkdir -p ${DIR} && cd ${DIR} && \
./configure \
--disable-debug \
--disable-doc \
--disable-ffplay \
--disable-shared \
--enable-static \
--enable-pthreads \
--enable-avresample \
--enable-libopencore-amrnb \
--enable-libopencore-amrwb \
--enable-gpl \
--enable-libass \
--enable-fontconfig \
--enable-libfreetype \
--enable-libvidstab \
--enable-libmp3lame \
--enable-libopus \
--enable-libtheora \
--enable-libvorbis \
--enable-libvpx \
--enable-libwebp \
--enable-libxcb \
--enable-libx265 \
--enable-libxvid \
--enable-libx264 \
--enable-nonfree \
--enable-openssl \
--enable-libfdk_aac \
--enable-postproc \
--enable-small \
--enable-version3 \
--enable-libbluray \
--enable-libzmq \
--enable-libkvazaar \
--extra-cflags="-I${PREFIX}/include" \
--extra-ldexeflags="-static" \
--extra-ldflags="-Wl,-V,-L${PREFIX}/lib" \
--extra-libs="-ldl -lpthread -lm -lz" \
--pkg-config-flags="--static" \
--prefix="${PREFIX}" && \
make && \
make install
