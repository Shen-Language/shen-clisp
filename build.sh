#!/bin/sh
set -e

if [ ! -d "./kernel/" ]; then
    ./fetch.sh
fi

clisp -i install.lsp
