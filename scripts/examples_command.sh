#!/bin/sh

cd examples
for d in */; do
    echo "Running '$@' in $d .."
    cd "$d"
    $@
    cd ..
done