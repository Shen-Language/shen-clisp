[![Shen Version](https://img.shields.io/badge/shen-20.0-blue.svg)](https://github.com/Shen-Language)
[![Build Status](https://travis-ci.org/Shen-Language/shen-clisp.svg?branch=master)](https://travis-ci.org/Shen-Language/shen-clisp)

# Shen CLisp

[Shen](http://www.shenlanguage.org) on [GNU Common Lisp](http://www.clisp.org/) by [Mark Tarver](http://marktarver.com/), with contributions by the [Shen Language Open Source Community](https://github.com/Shen-Language).

Fetch the kernel sources by running `./fetch.sh`/`fetch.bat`. This will download the [shen-sources](https://github.com/Shen-Language/shen-sources) release into a folder named `kernel`.

Build by running `./build.sh`/`build.bat`. This will generate a `shen.mem` file. If the `kernel` folder is not present, `fetch` will be called first.

Start the Shen REPL by running `./shen.sh`/`shen.bat`. If the `shen.mem` file is not present, `build` will be called first.

Shen files can be specified on the command line, in which case they will be run sequentially and the REPL will not be started by default. The REPL can still be started by invoking `(shen.shen)`.

The test suite can be run by running `./shen.sh testsuite.shen`/`shen.bat testsuite.shen`.
