#!/bin/sh

# run snarkd in a loop, so that if snarkd dies, we can restart it.

while [ 1 == 1 ]; do
    echo "Starting snarkd..."
    /home/sign/snarkd/snarkd
    sleep 10
done
