#!/bin/bash

main () {
    # go to the current dir where main.sh is located
    cd "$(dirname "$0")" 

    sudo ./build_libbsd.sh # 96.18 seconds

    sudo ./build_iproute2.sh # 42.25 seconds

    sudo ./build_libaio.sh # 2.17 seconds

    sudo ./build_libnftables.sh # 528.39 seconds

    sudo ./build_libgnutls.sh # 622.00 seconds libnftables needs to be built before libgnutls

    # total time: ~22min
}

main