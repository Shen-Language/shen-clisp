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

; Assumes *.kl files are in the current directory
; Assumes ./Native directory exists
; Creates *.native files in the ./Native directory
; Deletes *.kl files
; Creates shen.mem file
; Creates and deletes *.fas and *.intermed files over the course of running

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

(DEFUN boot (File)
  (LET* ((KlCode (openfile File))
         (LispCode (MAPCAR (FUNCTION (LAMBDA (X) (shen.kl-to-lisp NIL X))) KlCode))
         (LspFile (FORMAT NIL "~A.lsp" File)))
    (IF (PROBE-FILE LspFile) (DELETE-FILE LspFile))
    (writefile LspFile LispCode)))

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
  (LET* ((IntermedFile (FORMAT NIL "~A.intermed" File))
         (LspFile      (FORMAT NIL "~A.lsp" IntermedFile))
         (FasFile      (FORMAT NIL "~A.fas" IntermedFile))
         (LibFile      (FORMAT NIL "~A.lib" IntermedFile))
         (Read (read-in-kl File)))
    (DELETE-FILE IntermedFile)
    (write-out-kl IntermedFile Read)
    (boot IntermedFile)
    (COMPILE-FILE LspFile)
    (LOAD FasFile)
    (DELETE-FILE IntermedFile)
    (move-file LspFile)
    (DELETE-FILE FasFile)
    (DELETE-FILE LibFile)
    (DELETE-FILE File)))

(DEFUN move-file (Lisp)
  (LET ((Rename (native-name Lisp)))
    (IF (PROBE-FILE Rename) (DELETE-FILE Rename))
    (RENAME-FILE Lisp Rename)))

(DEFUN native-name (Lisp)
  (FORMAT NIL "Native/~{~C~}.native" (nn-h (COERCE Lisp 'LIST))))

(DEFUN nn-h (Lisp)
  (IF (CHAR-EQUAL (CAR Lisp) #\.)
      NIL
      (CONS (CAR Lisp) (nn-h (CDR Lisp)))))

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

(DEFUN flip (State) (IF (ZEROP State) 1 0))

(COMPILE 'read-in-kl)
(COMPILE 'kl-cycle)
(COMPILE 'flip)

(DEFUN write-out-kl (File Chars)
  (WITH-OPEN-FILE
    (Out File
      :DIRECTION         :OUTPUT
      :IF-EXISTS         :OVERWRITE
      :IF-DOES-NOT-EXIST :CREATE)
    (FORMAT Out "~{~C~}" Chars)))

(COMPILE 'write-out-kl)

(COMPILE-FILE "primitives.lsp")
(LOAD "primitives.fas")
(DELETE-FILE "primitives.fas")
(DELETE-FILE "primitives.lib")

(COMPILE-FILE "backend.lsp")
(LOAD "backend.fas")
(DELETE-FILE "backend.fas")
(DELETE-FILE "backend.lib")

(MAPC 'clisp-install
      '("toplevel.kl"
        "core.kl"
        "sys.kl"
        "sequent.kl"
        "yacc.kl"
        "reader.kl"
        "prolog.kl"
        "track.kl"
        "load.kl"
        "writer.kl"
        "macros.kl"
        "declarations.kl"
        "types.kl" 
        "t-star.kl"))

(COMPILE-FILE "overwrite.lsp")
(LOAD "overwrite.fas")
(DELETE-FILE "overwrite.fas")
(DELETE-FILE "overwrite.lib")
;(load "platform.shen") ; TODO - should this remain commented-out?

(MAPC 'FMAKUNBOUND '(boot writefile openfile))

(EXT:SAVEINITMEM "shen.mem" :INIT-FUNCTION 'shen.byteloop)

(QUIT)
