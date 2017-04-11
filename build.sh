#!/bin/sh

mkdir -p Native
cp -R klambda/. .
clisp -i install.lsp

