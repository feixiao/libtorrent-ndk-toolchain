#!/bin/bash
set -eu

DEST_ARCH=$1
echo "DEST_ARCH=$DEST_ARCH"
if [ -z "$DEST_ARCH" ]; then
    echo "You must specific an architecture 'armv7a, x86, arm64, x86_64...'."
    echo ""
    exit 1
fi

if [ -z "$ANDROID_NDK" -o -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK, ANDROID_SDK before starting."
    echo "They must point to your NDK and SDK directories.\n"
    exit 1
fi


ROOT_DIR=$PWD
ARCHS_32="armv7a x86"
ARCHS_64="arm64 x86_64"

ARCH_TYPE=
BUILD_NAME=
BOOST_PREFIX=
# 基础库目录
DEPS_PREFIX=/home/frank/deps/mobile_deps

if [[ "$DEST_ARCH" = "armv7a" ]]; then
    ARCH_TYPE="arm"
    # HOST_NAME="arm-linux-androideabi"
    BUILD_NAME=armeabi-v7a
    BOOST_PREFIX=${DEPS_PREFIX}/armeabi-v7a
    CC=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang
    CXX=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang++
    PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
# elif [[ "$DEST_ARCH" = "x86" ]]; then
#     ARCH_TYPE="x86"  
#     RANLIB_NAME="i686-linux-android-gcc-ranlib"
#     HOST_NAME="i686-linux-android-gcc"
#     BOOST_PREFIX=${DEPS_PREFIX}/x86
elif [[ "$DEST_ARCH" = "arm64" ]]; then
    ARCH_TYPE="arm64"  
    # HOST_NAME="aarch64-linux-android-gcc"
    BUILD_NAME=arm64-v8a
    BOOST_PREFIX=${DEPS_PREFIX}/arm64-v8a
    CC=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
    CXX=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++
    PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
elif [[ "$DEST_ARCH" = "x86_64" ]]; then
    ARCH_TYPE="x86_64"  
    BUILD_NAME=x86_64
    # HOST_NAME="x86_64-linux-android-gcc"
    BOOST_PREFIX=${DEPS_PREFIX}/x86_64
    CC=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang
    CXX=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang++
    PATH=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
else 
    echo "You must specific an architecture 'armv7a, arm64, x86_64, ...'."
    echo ""
    exit 1    
fi

BOOST_VERSION=1.69.0
LIBTORRENT_VERSION=1.2.12
LIBTORRENT_BRANCH=libtorrent_1_2_12
echo "start building libtorent_$LIBTORRENT_VERSION with boost_$BOOST_VERSION"

source lib_archive.sh

#init_boost $BOOST_VERSION
init_libtorrent $LIBTORRENT_BRANCH $LIBTORRENT_VERSION


cd $LIBTORRENT_DIR

echo "Building libtorrent_$LIBTORRENT_VERSION"

TORRENT_HOST=arm-linux-androideabi


echo "BOOST_PREFIX: ${BOOST_PREFIX}"
./configure --host=$TORRENT_HOST \
            --prefix=${ROOT_DIR}/build/${ARCH_TYPE} \
            --with-boost=${BOOST_PREFIX}/include/boost-1_69 \
            --with-boost-libdir=${BOOST_PREFIX}/lib \
			--enable-examples=no \
			--disable-encryption \
			--enable-tests=no \
		    --enable-shared=no \
            --enable-static=yes \
            --enable-debug=no 
            # --enable-loggin-yes

make -j8
make install