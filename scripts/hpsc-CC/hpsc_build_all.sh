#!/bin/bash

# (c) 2023 Microchip Technology Inc. 
# SPDX-License-Identifier: MIT 

printf "${BCyan}running script: hpsc_build_all.sh${Color_Off}\n"

. ./config.sh

echo "Please make your selection on 1 or 2 below."
echo "1 - cross compile CRIU with only required packages (~10min)"
echo "2 - cross compile CRIU with required and optional packages (~30min)"
read user_choice

case $user_choice in
  "1")
    echo "Building required dependencies..."
    . ./build_required_deps.sh
    ;;
  "2")
    echo "Building both required and optional dependencies..."
    . ./build_required_deps.sh
    . ./build_optional_deps.sh # libbsd (+ libmd), iproute2, libaio, libnftable (+ libnftnl, libmnnl, libgmp, libedit, libncurses), libgnutls (+ libnettle)
    ;;
  *)
    echo "Invalid input. Please type '1' or '2'."
    exit 1
    ;;
esac

. ./build_criu.sh

