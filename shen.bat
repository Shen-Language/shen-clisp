if not exist ".\shen.mem" call build.bat

clisp -M shen.mem -q -m 10MB
