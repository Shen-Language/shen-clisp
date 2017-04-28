#!/bin/sh
set -e

if [ ! -f "./shen.mem" ]; then
    ./build.sh
fi

clisp -M shen.mem -q -m 10MB $*
