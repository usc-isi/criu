#!/bin/sh

echo "running script: build_libnftables.sh"

. ./config.sh
. ./util.sh

LIBNFTABLES_GIT_URL="git://git.netfilter.org/nftables"
LIBNFTNL_GIT_URL="git://git.netfilter.org/libnftnl"
LIBMNL_GIT_URL="git://git.netfilter.org/libmnl"
LIBGMP_DOWNLOAD_URL="https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz"
LIBEDIT_DOWNLOAD_URL="https://www.thrysoee.dk/editline/libedit-20230828-3.1.tar.gz"
LIBNCURSES_DOWNLOAD_URL="https://invisible-island.net/datafiles/release/ncurses.tar.gz"
# LIBREADLINE_DOWNLOAD_URL="https://git.savannah.gnu.org/cgit/readline.git/snapshot/readline-8.2.tar.gz"

# download source code and extract it
download_extract () {
    wget -P $BUILD_ROOT_DIR $LIBGMP_DOWNLOAD_URL --quiet
    wget -P $BUILD_ROOT_DIR $LIBEDIT_DOWNLOAD_URL --quiet
    wget -P $BUILD_ROOT_DIR $LIBNCURSES_DOWNLOAD_URL --quiet

    tarball="$(basename -- $LIBGMP_DOWNLOAD_URL)"
    tar -xf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    

    tarball="$(basename -- $LIBEDIT_DOWNLOAD_URL)"
    tar -zxf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    

    tarball="$(basename -- $LIBNCURSES_DOWNLOAD_URL)"
    tar -zxf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    
}

# build_libreadline_riscv64 () {
#     export CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include"
#     export LDFLAGS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    
#     wget -P $BUILD_ROOT_DIR $LIBREADLINE_DOWNLOAD_URL --quiet
#     tarball="$(basename -- $LIBREADLINE_DOWNLOAD_URL)"
#     tar -xf $BUILD_ROOT_DIR/$tarball --directory $BUILD_ROOT_DIR    

#     printf "${BCyan}building libreadline for $TARGET_ARCH${Color_Off}\n"
#     cd "$BUILD_ROOT_DIR/readline-8.2" 
#     mkdir -p riscv64_build
#     cd riscv64_build
    
#     CC=riscv64-unknown-linux-gnu-gcc \
#     LD=riscv64-unknown-linux-gnu-ld \
#     AR=riscv64-unknown-linux-gnu-ar \
#     STRIP=riscv64-unknown-linux-gnu-strip \
#     ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
#     --enable-static --host=riscv64-unknown-linux-gnu

#     make && make install
# }   

build_libncurses_riscv64 () {
    printf "${BCyan}building libncurses for $TARGET_ARCH${Color_Off}\n"
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/ncurses-6.3" 
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    ../configure --disable-stripping --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}


build_libedit_riscv64 () {
    export CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include -I$BUILD_ROOT_DIR/riscv64_pb_install/include/ncurses"
    export LDFLAGS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    export CPPFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include -I$BUILD_ROOT_DIR/riscv64_pb_install/include/ncurses"

    printf "${BCyan}building libedit for $TARGET_ARCH${Color_Off}\n"
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/libedit-20230828-3.1" 
    mkdir -p riscv64_build
    cd riscv64_build

    CC=riscv64-unknown-linux-gnu-gcc \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_libgmp_riscv64 () {
    printf "${BCyan}building libgmp for $TARGET_ARCH${Color_Off}\n"
    # go to the folder where the extracted files are
    cd "$BUILD_ROOT_DIR/gmp-6.3.0" 
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_libmnl_riscv64 () {
    printf "${BCyan}building libmnl for $TARGET_ARCH${Color_Off}\n"
    # go to the folder where the extracted files are
    cd $BUILD_ROOT_DIR
    git clone $LIBMNL_GIT_URL
    cd libmnl

    ./autogen.sh
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_libnftnl_riscv64 () {
    printf "${BCyan}building libnftnl for $TARGET_ARCH${Color_Off}\n"
    export LIBMNL_CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include"
    export LIBMNL_LIBS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    # go to the folder where the extracted files are
    cd $BUILD_ROOT_DIR
    git clone $LIBNFTNL_GIT_URL
    cd libnftnl

    ./autogen.sh
    mkdir -p riscv64_build
    cd riscv64_build
    
    CC=riscv64-unknown-linux-gnu-gcc \
    CXX=riscv64-unknown-linux-gnu-g++ \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}

build_libnftables_riscv64 () {
    export LIBMNL_CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include"
    export LIBMNL_LIBS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    export LIBNFTNL_CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include"
    export LIBNFTNL_LIBS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    export LD_LIBRARY_PATH=$BUILD_ROOT_DIR/riscv64_pb_install/lib
    export LDFLAGS="-L$BUILD_ROOT_DIR/riscv64_pb_install/lib"
    # export LIBS="-ledit -lgmp -lnftnl -lmnl" # will break the build of libedit, but is needed for the build of nftables

    # go to the folder where the extracted files are
    cd $BUILD_ROOT_DIR
    git clone $LIBNFTABLES_GIT_URL
    cd nftables

    sudo apt-get install asciidoc # required by nftables
    measure_func_time build_libmnl_riscv64 # required by nftables 18.76 seconds
    measure_func_time build_libnftnl_riscv64 # required by nftables 48.05 seconds
    measure_func_time build_libgmp_riscv64 # required by nftables 203.69 seconds
    measure_func_time build_libncurses_riscv64 # required by nftables 155.53 seconds
    measure_func_time build_libedit_riscv64 # required by nftables 29.05 seconds

    ./autogen.sh
    mkdir -p riscv64_build
    cd riscv64_build
    mkdir -p ./doc
    
    CC=riscv64-unknown-linux-gnu-gcc \
    LD=riscv64-unknown-linux-gnu-ld \
    AR=riscv64-unknown-linux-gnu-ar \
    STRIP=riscv64-unknown-linux-gnu-strip \
    LDFLAGS=-L$BUILD_ROOT_DIR/riscv64_pb_install/lib \
    CFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    CPPFLAGS="-I$BUILD_ROOT_DIR/riscv64_pb_install/include" \
    LIBS="-ledit -lgmp -lnftnl -lmnl" \
    ../configure --prefix=$BUILD_ROOT_DIR/riscv64_pb_install \
    --enable-static --host=riscv64-unknown-linux-gnu

    make && make install
}


main () {

    download_extract

    case $TARGET_ARCH in
        
        "riscv64")
            printf "${BCyan}building libnftables for $TARGET_ARCH${Color_Off}\n"
            measure_func_time build_libnftables_riscv64 # total 533.31 seconds
            ;;

        *)
            echo "the target architecture $TARGET_ARCH is not supported, exit the program..."
            exit
            ;;
    esac
}

main