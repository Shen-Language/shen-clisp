#!/bin/sh
set -e

if [ ! -f "./kernel/" ]; then
    ./fetch.sh
fi

clisp -i install.lsp
