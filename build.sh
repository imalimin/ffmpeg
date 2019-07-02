#!/bin/bash
NDK=/Users/lmy/Library/Android/android-ndk-r14b
X264=$(pwd)/../x264/product

#--enable-jni
#--enable-mediacodec
#--enable-decoder=h264_mediacodec
#--enable-hwaccel=h264_mediacodec
build(){
  ARCH=$1
  PLATFORM=
  TOOLCHAIN=
  EXTRA_FF_FLAGS=
  EXTRA_CFLAGS=
  EXTRA_LDFLAGS=
  PREFIX=
  LIB_X264_STATIC=
  LIB_GCC=

  OS=linux-x86_64
  if [ ` uname -s ` = "Darwin" ]; then
    OS=darwin-x86_64
  fi

  if [ "$ARCH" = "armv7a" ]; then
    echo "------BUILD armv7a--------"
    PREFIX=$(pwd)/product/armeabi-v7a
    PLATFORM=$NDK/platforms/android-19/arch-arm
    TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}/bin/arm-linux-androideabi-
  	EXTRA_FF_FLAGS="${EXTRA_FF_FLAGS} --arch=arm --cpu=cortex-a8"
  	EXTRA_FF_FLAGS="${EXTRA_FF_FLAGS} --enable-neon"
  	EXTRA_FF_FLAGS="${EXTRA_FF_FLAGS} --enable-thumb  --enable-asm"
  	EXTRA_CFLAGS="$EXTRA_CFLAGS -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb -O3"
  	EXTRA_CFLAGS="$EXTRA_CFLAGS -I${X264}/armeabi-v7a/include"
  	EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,--fix-cortex-a8 -pie -fPIC"
  	EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L${X264}/armeabi-v7a/lib"

    LIB_X264_STATIC=$X264/armeabi-v7a/lib/libx264.a
    LIB_GCC=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a
  elif [ "$ARCH" = "x86" ]; then
    echo "------BUILD x86--------"
    PREFIX=$(pwd)/product/x86
    PLATFORM=$NDK/platforms/android-19/arch-x86
    TOOLCHAIN=$NDK/toolchains/x86-4.9/prebuilt/${OS}/bin/i686-linux-android-
  	EXTRA_FF_FLAGS="${EXTRA_FF_FLAGS} --arch=x86 --cpu=i686"
  	EXTRA_FF_FLAGS="${EXTRA_FF_FLAGS} --enable-yasm"
  	EXTRA_CFLAGS="$EXTRA_CFLAGS -march=atom -msse3 -ffast-math -mfpmath=sse -O3"
  	EXTRA_CFLAGS="$EXTRA_CFLAGS -I${X264}/x86/include"
    EXTRA_LDFLAGS="$EXTRA_LDFLAGS -pie -fPIC"
  	EXTRA_LDFLAGS="$EXTRA_LDFLAGS -L${X264}/x86/lib"

    LIB_X264_STATIC=$X264/x86/lib/libx264.a
    LIB_GCC=$NDK/toolchains/x86-4.9/prebuilt/${OS}/lib/gcc/i686-linux-android/4.9.x/libgcc.a
  else
    echo "Need a arch param"
    exit 1
  fi
  ./configure \
  	--prefix=$PREFIX \
  	--target-os=android \
  	--sysroot=$PLATFORM \
  	--enable-cross-compile \
    --cross-prefix=$TOOLCHAIN \
    --cc=${TOOLCHAIN}gcc \
    --nm=${TOOLCHAIN}nm \
  	--disable-debug \
  	\
  	--disable-shared \
  	--enable-static \
  	\
  	--disable-doc \
  	--enable-gpl \
  	--enable-nonfree \
  	--disable-w32threads \
  	--disable-programs \
  	--disable-ffplay \
  	--disable-ffprobe \
  	--disable-avdevice \
  	\
  	--disable-avdevice \
  	--disable-swscale \
  	--disable-postproc \
  	--disable-avfilter \
  	--enable-avresample \
  	--disable-network \
  	--disable-filters \
  	\
  	--disable-encoders \
  	--disable-decoders \
  	\
    --enable-jni \
    --enable-mediacodec \
    --enable-hwaccel=h264_mediacodec \
    \
  	--enable-libx264 \
  	--enable-encoder=libx264 \
  	--enable-encoder=aac \
  	\
    --enable-decoder=h264_mediacodec \
  	--enable-decoder=h264 \
  	--enable-decoder=aac \
  	\
  	--extra-cflags="$EXTRA_CFLAGS" \
  	--extra-ldflags="$EXTRA_LDFLAGS" \
  	$EXTRA_FF_FLAGS

  make clean
  make -j4
  make install

  ${TOOLCHAIN}ld \
    --sysroot=$PLATFORM \
    --allow-shlib-undefined \
    -rpath-link=$PLATFORM/usr/lib \
    -L$PLATFORM/usr/lib \
    -L$PREFIX/lib \
    -soname libhwffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive -O3 \
    -o $PREFIX/libhwffmpeg.so \
    $PREFIX/lib/libavcodec.a \
    $PREFIX/lib/libavformat.a \
    $PREFIX/lib/libavresample.a \
    $PREFIX/lib/libavutil.a \
    $PREFIX/lib/libswresample.a \
    $LIB_X264_STATIC \
    -lc -lm -lz -ldl -llog \
    $LIB_GCC
    #--no-undefined \
}

build $1