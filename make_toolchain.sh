#!/bin/bash

make_toolchain(){
  local path=$3/my/android-$1/$2
  # --force
  python $3/build/tools/make_standalone_toolchain.py --api $1 --install-dir $path --arch $2 --stl libc++
  echo $path
}

api=$1
arch=$2
ndk=$3
if [ "$api" = "" ]; then
  echo "Need a api param"
  exit 1
fi

if [ "$ndk" = "" ]; then
  echo "Input a ndk root dir pls"
  exit 1
fi

if [ "$arch" = "arm" ]; then
  arch=arm
elif [ "$arch" = "arm64" ]; then
  arch=arm64
elif [ "$arch" = "x86" ]; then
  arch=x86
else
  echo "Need a arch param.(Current is ${arch})"
  exit 1
fi

make_toolchain $api $arch $ndk