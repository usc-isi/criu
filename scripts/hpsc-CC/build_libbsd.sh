#!/bin/bash

echo "running script: build_libbsd.sh"

. ./config.sh
. ./util.sh

LIBBSD_GIT_URL="https://gitlab.freedesktop.org/libbsd/libbsd.git"

LIBMD_GIT_URL="https://git.hadrons.org/git/libmd.git" # libbsd requires libmd

build_libmd_riscv64 () {
    cd $BUILD_ROOT_DIR
    git clone $LIBMD_GIT_URL
    cd libmd

    ./autogen
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_libbsd_riscv64 () {
    cd $BUILD_ROOT_DIR
    git clone $LIBBSD_GIT_URL
    cd libbsd

    ./autogen
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LDFLAGS=-L$LIB_DIR_CC \
    CPPFLAGS=-I$INCLUDE_DIR_CC \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

main () {

    
    case $TARGET_ARCH in
        
        "riscv64")
            printf "${BCyan}building libmd for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libmd_riscv64
            printf "${BCyan}building libbsd for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libbsd_riscv64  
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main