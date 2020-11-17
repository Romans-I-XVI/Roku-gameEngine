#!/bin/sh

cd examples
for d in */; do
    echo "Running 'ropm install' in $d .."
    cd "$d"
    ropm install
    cd ..
done