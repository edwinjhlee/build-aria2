#! /usr/bin/env bash

set -o errexit

export WORKDIR=$(pwd)

apt-get update && \
    apt-get install -y make binutils autoconf automake autotools-dev libtool \
    pkg-config git curl dpkg-dev autopoint libcppunit-dev libxml2-dev \
    libgcrypt11-dev lzip upx


export LOCAL_DIR="$WORKDIR/local"
mkdir -p $LOCAL_DIR

# git clone https://github.com/raspberrypi/tools.git --depth=1 $(WORKDIR)/tools
# export TOOL_BIN_DIR=/tools/arm-bcm2708/gcc-linaro-$HOST-raspbian-x64/bin
# export PATH=${TOOL_BIN_DIR}:$PATH

# export ARCH=armhf
# export HOST=arm-linux-gnueabihf

build.zip(){

    cd $WORKDIR && mkdir -p zlib && cd zlib && \
        curl -Ls -o - 'http://zlib.net/zlib-1.2.11.tar.gz'  | \
                tar xzf - --strip-components=1 && \
        prefix=${LOCAL_DIR} \
        CC=gcc \
        STRIP=strip \
        RANLIB=ranlib \
        AR=ar \
        LD=ld \
        ./configure --static \
                --libdir=$LOCAL_DIR/lib && \
        make -s && \
        make -s install
}

build.expat(){
    cd $WORKDIR && mkdir -p expat && cd expat && \
        curl -Ls -o - 'https://sourceforge.net/projects/expat/files/expat/2.2.0/expat-2.2.0.tar.bz2/download' | \
            tar xjf - --strip-components=1 && \
        ./configure \
            --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
            --enable-shared=no \
            --enable-static=yes \
            --prefix=${LOCAL_DIR} && \
        make -s && \
        make -s install
}

build.c-ares(){
    cd $WORKDIR && mkdir -p c-ares && cd c-ares && \
        curl -Ls -o - 'http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz' | \
            tar xzf - --strip-components=1 && \
        ./configure \
            --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
            --enable-shared=no \
            --enable-static=yes \
            --prefix=${LOCAL_DIR} && \
        make -s && \
        make -s install
}

build.gmp(){
    cd $WORKDIR && mkdir -p gmp && cd gmp && \
        curl -Ls -o - 'https://gmplib.org/download/gmp/gmp-6.1.0.tar.lz' | \
            lzip -d | tar xf - --strip-components=1 && \
        ./configure \
            --disable-shared \
            --enable-static \
            --prefix=$LOCAL_DIR \
            --host=$HOST \
            --disable-cxx \
            --enable-fat && \
        make -s && \
        make -s install
}

build.sqlite(){

    cd $WORKDIR && mkdir -p sqlite && cd sqlite && \
        curl -Ls -o - 'https://www.sqlite.org/2016/sqlite-autoconf-3100100.tar.gz' | \
            tar xzf - --strip-components=1 && \
        ./configure \
            --disable-shared \
            --enable-static \
            --prefix=$LOCAL_DIR \
            --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` && \
        make -s && \
        make -s install
}

build.aria(){

    cd $WORKDIR && mkdir -p aria && cd aria && \
        curl -s 'https://api.github.com/repos/aria2/aria2/releases/latest' | \
            grep 'browser_download_url.*[0-9]\.tar\.bz2' | sed -e 's/^[[:space:]]*//' | \
            cut -d ' ' -f 2 | xargs -I % curl -Ls -o - '%' | tar xjf - --strip-components=1 && \
        ./configure \
            --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
            --disable-nls \
            --disable-ssl \
            --without-gnutls \
            --without-libxml2 \
            --with-libz     --with-libz-prefix=${LOCAL_DIR} \
            --with-libexpat --with-libexpat-prefix=${LOCAL_DIR} \
            --with-slite3   --with-sqlite3-prefix=${LOCAL_DIR} \
            --with-libcares --with-libcares-prefix=${LOCAL_DIR} \
            --prefix=${LOCAL_DIR} \
            LDFLAGS="-L$LOCAL_DIR/lib" \
            PKG_CONFIG_PATH="$LOCAL_DIR/lib/pkgconfig" \
            ARIA2_STATIC=yes && \
        make -s && \
        make -s "install-strip"
}

prepare.aria.bin(){
    cd $WORKDIR && mkdir -p bin && cd bin
    cp $LOCAL_DIR/bin/aria2c ./aria2c.linux
    cp $LOCAL_DIR/bin/aria2c ./aria2c.linux.upx
    upx ./aria2c.linux.upx
}

build.zip
build.expat
build.c-ares
build.gmp
build.sqlite
build.aria

prepare.aria.bin

