#!/bin/bash

echo "running script: build_iproute2.sh"

. ./config.sh
. ./util.sh

IPROUTE2_GIT_URL="git://git.kernel.org/pub/scm/network/iproute2/iproute2.git"

build_iproute2_riscv64 () {
    export CROSS_COMPILE=riscv64-unknown-linux-gnu-
    export CC=${CROSS_COMPILE}gcc
    export AR=${CROSS_COMPILE}ar
    export PKG_CONFIG_LIBDIR=$LIB_DIR_CC/pkgconfig:$LIB64_DIR_CC/pkgconfig #override PKG_CONFIG_PATH for cross compiling

    cd $BUILD_ROOT_DIR
    if [ ! -d "iproute2" ]; then        
        git clone $IPROUTE2_GIT_URL
    fi
    cd iproute2
    git checkout tags/v6.7.0

    ./configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

main () {

    
    case $TARGET_ARCH in
        
        "riscv64")
            printf "${BCyan}building iproute2 for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_iproute2_riscv64  
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main