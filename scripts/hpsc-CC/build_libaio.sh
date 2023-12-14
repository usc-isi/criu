#!/bin/sh

echo "running script: build_libaio.sh"

. ./config.sh
. ./util.sh

LIBAIO_DOWNLOAD_URL="https://pagure.io/libaio/archive/libaio-0.3.113/libaio-libaio-0.3.113.tar.gz"

build_libaio_riscv64 () {
    wget -P $BUILD_ROOT_DIR $LIBAIO_DOWNLOAD_URL --quiet
    tarball="$(basename -- $LIBAIO_DOWNLOAD_URL)"
    tar -zxf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR   

    cd "$BUILD_ROOT_DIR/libaio-libaio-0.3.113" 
    make CC=riscv64-unknown-linux-gnu-gcc prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    && make install CC=riscv64-unknown-linux-gnu-gcc prefix=$BUILD_ROOT_DIR/riscv64_pb_install
}


main () {

    case $TARGET_ARCH in
        
        "riscv64")
            printf "${BCyan}building libaio for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libaio_riscv64
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main