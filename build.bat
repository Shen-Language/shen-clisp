if not exist "Native" mkdir Native
cp -R klambda\* .
clisp -i install.lsp
