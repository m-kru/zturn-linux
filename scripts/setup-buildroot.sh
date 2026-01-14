#!/usr/bin/env bash

BUILDROOT_VERSION=2025.02.9
BUILDROOT_TAR="buildroot-$BUILDROOT_VERSION.tar.gz"
BUILDROOT_DIR="buildroot-$BUILDROOT_VERSION"

set -e

mkdir -p cache
cd cache
if [ ! -e $BUILDROOT_TAR ]; then
  wget "https://buildroot.org/downloads/$BUILDROOT_TAR"
fi
cd ..

mkdir -p build
cd build
if [ ! -d $BUILDROOT_DIR ]; then
  tar -xvf ../cache/$BUILDROOT_TAR
fi

cd $BUILDROOT_DIR
ln -s -f ../../config/buildroot .config
