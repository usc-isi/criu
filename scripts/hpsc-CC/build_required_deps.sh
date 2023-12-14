#!/bin/bash

main () {
    # go to the current dir where main.sh is located
    cd "$(dirname "$0")" 

    ./build_protobuf.sh # 135.72 seconds

    ./build_libnet.sh # 28.99 seconds

    ./build_libnl.sh # 175.22 seconds

    ./build_libcap.sh # 5.59 seconds

    # total time: ~6min
}

main