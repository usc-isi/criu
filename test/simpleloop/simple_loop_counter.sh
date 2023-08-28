#!/bin/sh
counter=1
while :; do
    sleep 1
    echo "HPSC CRIU testing $counter"
    counter=$((counter + 1))
done