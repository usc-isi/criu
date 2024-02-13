#!/bin/sh

cp -rn /mnt/build/criu-dependencies/riscv64_pb_install/lib/* /usr/lib/
mkdir -p /usr/lib64
cp -rn /mnt/build/criu-dependencies/riscv64_pb_install/lib64/* /usr/lib64/

echo "QEMU setup complete"