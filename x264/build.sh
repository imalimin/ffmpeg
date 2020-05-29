#!/bin/bash
NDK=${ANDROID_NDK}
ANDROID_VER=21
export TEMDIR=$(pwd)/.tmp

function guess_arch(){
  local arch=$1
  if [ "$arch" = "armv7a" ]; then
    arch=arm
  elif [ "$arch" = "arm64" ]; then
    arch=arm64
  elif [ "$arch" = "x86" ]; then
    arch=x86
  else
    echo "Need a arch param"
    exit 1
  fi
  echo $arch
  return $?
}

build(){
  local arch=$1
  TOOLCHAIN=
  HOST=
  EXTRA_CFLAGS=
  EXTRA_LDFLAGS=
  EXTRA_X264_FLAGS="--bit-depth=8 --chroma-format=420 --enable-strip --enable-pic --disable-avs --disable-swscale --disable-lavf --disable-ffms --disable-gpac"
  PREFIX=

  OS=linux-x86_64
  if [ ` uname -s ` = "Darwin" ]; then
    OS=darwin-x86_64
  fi

  ANDROID_TOOLCHAIN=$(../make_toolchain.sh $ANDROID_VER $arch $NDK)
  PLATFORM=${ANDROID_TOOLCHAIN}/sysroot
  echo "USE ${ANDROID_TOOLCHAIN}"
  if [ "$arch" = "arm" ]; then
    echo "------BUILD armv7a--------"
    PREFIX=$(pwd)/product/armeabi-v7a
    TOOLCHAIN=${ANDROID_TOOLCHAIN}/bin/arm-linux-androideabi-
    HOST=arm-linux-androideabi
    EXTRA_CFLAGS="${EXTRA_FLAGS} -fPIC -marm -DX264_VERSION -DANDROID -DHAVE_PTHREAD -DNDEBUG -DANDROID_DEPRECATED_HEADERS=ON -static -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__"
    EXTRA_FLAGS="${EXTRA_FLAGS} -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math"
    EXTRA_LDFLAGS="${EXTRA_LDFLAGS} L${ANDROID_TOOLCHAIN}/sysroot/usr/lib"
  elif [ "$arch" = "arm64" ]; then
    echo "------BUILD arm64--------"
    PREFIX=$(pwd)/product/arm64-v8a
    TOOLCHAIN=${ANDROID_TOOLCHAIN}/bin/aarch64-linux-android-
    HOST=aarch64-linux-android
    EXTRA_CFLAGS="${EXTRA_FLAGS} -fPIC -marm -DX264_VERSION -DANDROID -DHAVE_PTHREAD -DNDEBUG -static"
    EXTRA_CFLAGS="${EXTRA_FLAGS} -Os -mfpu=neon"
    EXTRA_FLAGS="${EXTRA_FLAGS} -mfloat-abi=softfp -ftree-vectorize -mvectorize-with-neon-quad -ffast-math"
  elif [ "$arch" = "x86" ]; then
    echo "------BUILD x86--------"
    PREFIX=$(pwd)/product/x86
    TOOLCHAIN=${ANDROID_TOOLCHAIN}/bin/i686-linux-android-
    HOST=i686-linux-android
    EXTRA_CFLAGS="${EXTRA_FLAGS} -fPIC -DX264_VERSION -DANDROID -DHAVE_PTHREAD -DNDEBUG"
    EXTRA_CFLAGS="${EXTRA_FLAGS} -static -Os -march=atom -mtune=atom -mssse3 -ffast-math -ftree-vectorize -mfpmath=sse"
    EXTRA_X264_FLAGS="${EXTRA_X264_FLAGS} --disable-asm"
  else
    echo "Not support arch for ${1}. Input arm, arm64 or x86 pls."
    exit 1
  fi

  ./configure \
  --prefix=$PREFIX \
  --enable-pic \
  --enable-static \
  --host=$HOST \
  --cross-prefix=$TOOLCHAIN \
  --sysroot=$PLATFORM \
  --extra-cflags=${EXTRA_CFLAGS} \
  $EXTRA_X264_FLAGS

  make clean
  make -j4
  make install
}

arch=$1
build $arch
