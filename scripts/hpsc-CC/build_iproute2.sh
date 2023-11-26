#!/bin/bash

echo "running script: build_iproute2.sh"

. ./config.sh
. ./util.sh

IPROUTE2_GIT_URL="git://git.kernel.org/pub/scm/network/iproute2/iproute2.git"

build_iproute2_riscv64 () {
    cd $BUILD_ROOT_DIR
    git clone $IPROUTE2_GIT_URL
    cd iproute2

    # mkdir -p riscv64_build
    # cd riscv64_build
    
    make CROSS_COMPILE=riscv64-unknown-linux-gnu- BUILD_CC=gcc && make install CROSS_COMPILE=riscv64-unknown-linux-gnu-

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