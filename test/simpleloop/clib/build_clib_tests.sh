#!/bin/bash

printf "${BCyan}running script: build_libcriu_test.sh${Color_Off}\n"

source ../../../scripts/hpsc-CC/config.sh

cd $CRIU_ROOT_DIR

export PATH=$BUILD_ROOT_DIR/x86_64_pb_install/bin:$PATH
# export PKG_CONFIG_PATH=$BUILD_ROOT_DIR/arm64_pb_install/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_LIBDIR=$LIB_DIR_CC/pkgconfig:$LIB64_DIR_CC/pkgconfig #override PKG_CONFIG_PATH for cross compiling

CFLAGS=$(pkg-config --cflags libprotobuf-c)
CFLAGS+=" -I$INCLUDE_DIR_CC -I$CRIU_ROOT_DIR/lib/c/ -I$CRIU_ROOT_DIR/images/ -L$LIB_DIR_CC"


LDFLAGS=$(pkg-config --libs libprotobuf-c)
# LDFLAGS+=" -rpath /usr/aarch64-linux-gnu/lib"
# LDFLAGS+=" -rpath $TOOLCHAIN_LIB_DIR"

cd $CRIU_ROOT_DIR/test/simpleloop/clib
# V=1 \
ARCH=riscv64 \
CC=riscv64-unknown-linux-gnu-gcc \
CFLAGS=$CFLAGS \
LDFLAGS=$LDFLAGS \
make -f Makefile-CC