#!/bin/bash

echo "running script: build_libcap.sh"

. ./config.sh
. ./util.sh

# LIBCAP_DOWNLOAD_URL="https://www.tcpdump.org/release/libpcap-1.10.3.tar.gz"
LIBCAP_DOWNLOAD_URL="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-2.69.tar.gz"

# download source code and extract it
download_extract () {
    wget -P $BUILD_ROOT_DIR $LIBCAP_DOWNLOAD_URL --quiet

    tarball="$(basename -- $LIBCAP_DOWNLOAD_URL)"
    tar -zxf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    
}


# build the arm64 version -- this is for libPcap, NOT libcap
# build_libcap_arm64 () {
#     # go to the folder where the extracted files are
#     cd "$BUILD_ROOT_DIR/libpcap-1.10.3" 

#     mkdir -p arm64_build
#     cd arm64_build
    
#     CC=aarch64-linux-gnu-gcc \
#     CXX=aarch64-linux-gnu-g++ \
#     CFLAGS="-Os" \
#     ../configure --prefix=$BUILD_ROOT_DIR/arm64_pb_install \
#     --enable-static --host=aarch64-unknown-linux-gnu

#     make && make install
# }

# build the riscv64 version 
build_libcap_riscv64_prep () {
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/libcap-2.69" 
    make CROSS_COMPILE=riscv64-unknown-linux-gnu-
}

build_libcap_riscv64 () {
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/libcap-2.69" 
    make CROSS_COMPILE=riscv64-unknown-linux-gnu- && make install CROSS_COMPILE=riscv64-unknown-linux-gnu-
}

main () {
    download_extract

    case $TARGET_ARCH in
        "aarch64" | "arm64")
            printf "${BCyan}building libcap for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libcap_arm64
            ;;
        
        "riscv64")
            printf "${BCyan}building libcap for $TARGET_ARCH${Color_Off}\n"
            printf "is this your first time running this script? (y/n) \n"
            read user_input

            case $user_input in
                y|Y)
                    printf "expect error and run the script again. choose n next time\n press Enter to continue \n"
                    read dummy_input
                    measure_func_time build_libcap_riscv64_prep
                    ;;
                n|N)
                    cd "$BUILD_ROOT_DIR/libcap-2.69/libcap"
                    gcc -o _makenames _makenames.c
                    # gcc -o empty empty.c
                    cd "$BUILD_ROOT_DIR/libcap-2.69"
                    measure_func_time build_libcap_riscv64
                    ;;
                *)
                    echo "Invalid input. Please enter 'y' or 'n'."
                    exit 1
                    ;;
            esac
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main