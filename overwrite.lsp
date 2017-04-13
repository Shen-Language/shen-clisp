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

(DEFUN shen.pvar? (X) (IF (AND (ARRAYP X) (NOT (STRINGP X)) (EQ (SVREF X 0) 'shen.pvar))
                          'true
                          'false))

(DEFUN shen.lazyderef (X ProcessN)
   (IF (AND (ARRAYP X) 
            (NOT (STRINGP X)) (EQ (SVREF X 0) 'shen.pvar))
       (LET ((Value (shen.valvector X ProcessN)))
            (IF (EQ Value 'shen.-null-)
                X
                (shen.lazyderef Value ProcessN)))
       X))

(DEFUN shen.valvector (Var ProcessN)
  (SVREF (SVREF shen.*prologvectors* ProcessN) (SVREF Var 1)))

(DEFUN shen.unbindv (Var N)
  (LET ((Vector (SVREF shen.*prologvectors* N)))
       (SETF (SVREF Vector (SVREF Var 1)) 'shen.-null-)))

(DEFUN shen.bindv (Var Val N)
   (LET ((Vector (SVREF shen.*prologvectors* N)))
        (SETF (SVREF Vector (SVREF Var 1)) Val)))

(DEFUN shen.copy-vector-stage-1 (V2828 V2829 V2830 V2831)
 (COND ((= V2831 V2828) V2830)
  (T
   (shen.copy-vector-stage-1 (1+ V2828) V2829
    (address-> V2830 V2828 (<-address V2829 V2828)) V2831))))

(DEFUN shen.copy-vector-stage-2 (V2835 V2836 V2837 V2838)
 (COND ((= V2836 V2835) V2838)
  (T
   (shen.copy-vector-stage-2 (1+ V2835) V2836 V2837
    (address-> V2838 V2835 V2837)))))

(DEFUN shen.newpv (N)
  (LET ((Count+1 (1+ (THE INTEGER (SVREF shen.*varcounter* N))))
        (Vector (SVREF shen.*prologvectors* N)))
       (SETF (SVREF shen.*varcounter* N) Count+1)
       (IF (= (THE INTEGER Count+1) (THE INTEGER (limit Vector)))
           (shen.resizeprocessvector N Count+1)
           'skip)
       (shen.mk-pvar Count+1)))

(DEFUN vector-> (Vector N X)
  (IF (ZEROP N)
      (ERROR "cannot access 0th element of a vector~%")
      (address-> Vector N X)))

(DEFUN <-vector (Vector N)
  (IF (ZEROP N)
      (ERROR "cannot access 0th element of a vector~%")
       (let VectorElement (SVREF Vector N)
          (IF (EQ VectorElement (fail))
              (ERROR "vector element not found~%")
              VectorElement))))

(DEFUN variable? (X)
 (IF (AND (SYMBOLP X) (NOT (NULL X)) (UPPER-CASE-P (CHAR (SYMBOL-NAME X) 0)))
     'true
     'false))

(DEFUN shen.+string? (X) (IF (AND (STRINGP X) (NOT (STRING-EQUAL X "")))
                            'true
                            'false))

(DEFUN thaw (F) (FUNCALL F))

(DEFUN shen.byteloop ()
 (HANDLER-BIND
    ((WARNING #'MUFFLE-WARNING))
 (WITH-OPEN-STREAM
  (*STANDARD-INPUT* (EXT:MAKE-STREAM
                        :INPUT
                        :ELEMENT-TYPE 'UNSIGNED-BYTE))
    (WITH-OPEN-STREAM (*STANDARD-OUTPUT*
                        (EXT:MAKE-STREAM
                           :OUTPUT
                           :ELEMENT-TYPE 'UNSIGNED-BYTE))
    (SETQ *stoutput* *STANDARD-OUTPUT*)
    (SETQ *stinput* *STANDARD-INPUT*)
    (shen.shen)))))

(DEFUN shen.lookup-func (F SymbolTable)
   (LET ((Entry (ASSOC F SymbolTable :TEST 'EQ)))
      (IF (NULL Entry)
          (ERROR "~A has no lambda expansion~%" F)
          (CDR Entry))))
