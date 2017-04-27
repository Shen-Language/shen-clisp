"Copyright (c) 2010-2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

; Assumes *.kl files are in the ./kernel/klambda directory
; Creates *.intermed, *.lsp, *.fas and *.lib files in the ./native directory
; Creates shen.mem file in the current directory

(ENSURE-DIRECTORIES-EXIST "./native/")

(PROCLAIM '(OPTIMIZE (DEBUG 0) (SPEED 3) (SAFETY 3)))
(SETQ CUSTOM:*COMPILE-WARNINGS* NIL)
(SETQ *COMPILE-VERBOSE* NIL)
(IN-PACKAGE :CL-USER)

(SETF (READTABLE-CASE *READTABLE*) :PRESERVE)
(SETQ *language* "Common Lisp")
(SETQ *implementation* (LISP-IMPLEMENTATION-TYPE))
(SETQ *release*
  (LET ((V (LISP-IMPLEMENTATION-VERSION)))
    (SUBSEQ V 0 (POSITION #\Space V :START 0))))
(SETQ *port* 2.0)
(SETQ *porters* "Mark Tarver")
(SETQ *os*
  (COND
    ((FIND :WIN32 *FEATURES*) "Windows")
    ((FIND :LINUX *FEATURES*) "Linux")
    ((FIND :OSX *FEATURES*) "Mac OSX")
    ((FIND :UNIX *FEATURES*) "Unix")))

(DEFUN boot (InputFile OutputFile)
  (LET* ((KlCode (openfile InputFile))
         (LispCode (MAPCAR (FUNCTION (LAMBDA (X) (shen.kl-to-lisp NIL X))) KlCode)))
    (writefile OutputFile LispCode)))

(DEFUN writefile (File Out)
  (WITH-OPEN-FILE
    (OUTSTREAM File
      :DIRECTION         :OUTPUT
      :IF-EXISTS         :OVERWRITE
      :IF-DOES-NOT-EXIST :CREATE)
    (FORMAT OUTSTREAM "~%")
    (MAPC (FUNCTION (LAMBDA (X) (FORMAT OUTSTREAM "~S~%~%" X))) Out)
    File))

(DEFUN openfile (File)
  (WITH-OPEN-FILE (In File :DIRECTION :INPUT)
    (DO ((R T) (Rs NIL))
        ((NULL R) (NREVERSE (CDR Rs)))
        (SETQ R (READ In NIL NIL))
        (PUSH R Rs))))

(DEFUN clisp-install (File)
  (LET ((KlFile       (FORMAT NIL "./kernel/klambda/~A.kl" File))
        (IntermedFile (FORMAT NIL "./native/~A.intermed" File))
        (LspFile      (FORMAT NIL "./native/~A.lsp" File))
        (FasFile      (FORMAT NIL "./native/~A.fas" File))
        (LibFile      (FORMAT NIL "./native/~A.lib" File)))
    (write-out-kl IntermedFile (read-in-kl KlFile))
    (boot IntermedFile LspFile)
    (COMPILE-FILE LspFile)
    (LOAD FasFile)))

(DEFUN read-in-kl (File)
  (WITH-OPEN-FILE
    (In File :DIRECTION :INPUT)
    (kl-cycle (READ-CHAR In NIL NIL) In NIL 0)))

(DEFUN kl-cycle (Char In Chars State)
  (COND
    ((NULL Char)
     (REVERSE Chars))
    ((AND (MEMBER Char '(#\: #\; #\,) :TEST 'CHAR-EQUAL) (= State 0))
     (kl-cycle (READ-CHAR In NIL NIL) In (APPEND (LIST #\| Char #\|) Chars) State))
    ((CHAR-EQUAL Char #\")
     (kl-cycle (READ-CHAR In NIL NIL) In (CONS Char Chars) (flip State)))
    (T
     (kl-cycle (READ-CHAR In NIL NIL) In (CONS Char Chars) State))))

(DEFUN flip (State)
  (IF (ZEROP State) 1 0))

(DEFUN write-out-kl (File Chars)
  (WITH-OPEN-FILE
    (Out File
      :DIRECTION         :OUTPUT
      :IF-EXISTS         :OVERWRITE
      :IF-DOES-NOT-EXIST :CREATE)
    (FORMAT Out "~{~C~}" Chars)))

(DEFUN importfile (File)
  (LET ((LspFile (FORMAT NIL "~A.lsp" File))
        (FasFile (FORMAT NIL "./native/~A.fas" File)))
    (COMPILE-FILE LspFile :OUTPUT-FILE FasFile)
    (LOAD FasFile)))

(COMPILE 'read-in-kl)
(COMPILE 'kl-cycle)
(COMPILE 'flip)
(COMPILE 'write-out-kl)

(importfile "primitives")
(importfile "backend")

(MAPC
  'clisp-install
  '("toplevel"
    "core"
    "sys"
    "sequent"
    "yacc"
    "reader"
    "prolog"
    "track"
    "load"
    "writer"
    "macros"
    "declarations"
    "types"
    "t-star"))

(importfile "overwrite")
(load "platform.shen")

(MAPC 'FMAKUNBOUND '(safedelete boot writefile openfile importfile))

(EXT:SAVEINITMEM "shen.mem" :INIT-FUNCTION 'shen.byteloop)

(QUIT)
