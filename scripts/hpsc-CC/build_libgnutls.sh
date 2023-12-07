#!/bin/sh

echo "running script: build_gnutls.sh"

. ./config.sh
. ./util.sh

GNUTLS_DOWNLOAD_URL="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.7/gnutls-3.7.10.tar.xz"
LIBNETTE_DOWNLOAD_URL="https://ftp.gnu.org/gnu/nettle/nettle-3.9.tar.gz"

# download source code and extract it, including both libnet and libnet-c
download_extract () {
    wget -P $BUILD_ROOT_DIR $GNUTLS_DOWNLOAD_URL --quiet
    wget -P $BUILD_ROOT_DIR $LIBNETTE_DOWNLOAD_URL --quiet

    tarball="$(basename -- $GNUTLS_DOWNLOAD_URL)"
    tar -xf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    

    tarball="$(basename -- $LIBNETTE_DOWNLOAD_URL)"
    tar -zxf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    
}

build_libnettle_riscv64 ()
{
    printf "${BCyan}building libnettle for $TARGET_ARCH${Color_Off}\n"
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/nettle-3.9" 

    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    LDFLAGS=-L$BUILD_ROOT_DIR/riscv64_pb_install/lib \
    CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    CPPFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    LIBS="-lgmp" \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_gnutls_riscv64 () {
    export PKG_CONFIG_PATH=$BUILD_ROOT_DIR/riscv64_pb_install/lib/pkgconfig:$PKG_CONFIG_PATH
    export LD_LIBRARY_PATH=$BUILD_ROOT_DIR/riscv64_pb_install/lib
    export LDFLAGS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"

    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/gnutls-3.7.10" 

    mkdir -p riscv64_build
    cd riscv64_build

    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    LDFLAGS=-L$BUILD_ROOT_DIR/riscv64_pb_install/lib \
    CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    CPPFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    LIBS="-lgmp" \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --with-included-libtasn1 --with-included-unistring \
    --without-p11-kit --without-brotli \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}


main () {
    
    download_extract

    case $TARGET_ARCH in
        
        "riscv64")
            printf "${BCyan}building gnutls for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libnettle_riscv64 # 60.65 seconds
            measure_func_time build_gnutls_riscv64 # 630.35 seconds
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main