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

(DEFUN shen.mk-kl (V646) (LET ((Shen (read-file V646))) (LET ((KL (MAPCAR (QUOTE shen.produce-kl) Shen))) (LET ((KLString (shen.code-string KL))) (LET ((WriteKL (write-to-file (cn V646 ".kl") KLString))) (LET ((CL (MAPCAR (FUNCTION (LAMBDA (X) (shen.kl-to-lisp () X))) KL))) (LET ((CLString (shen.code-string CL))) (LET ((WriteCL (write-to-file (cn V646 ".lsp") CLString))) (QUOTE shen.ok))))))))) 

(DEFUN shen.produce-kl (V647) (COND ((AND (CONSP V647) (AND (EQ (QUOTE define) (CAR V647)) (CONSP (CDR V647)))) (shen.shen->kl (CAR (CDR V647)) (CDR (CDR V647)))) (T V647))) 

(DEFUN shen.code-string (V648) (COND ((NULL V648) "") ((CONSP V648) (cn (shen.app (CAR V648) " 

" (QUOTE shen.r)) (shen.code-string (CDR V648)))) (T (shen.f_error (QUOTE shen.code-string))))) 

(DEFUN shen.kl-to-lisp (V660 V661) (COND ((CONSP (MEMBER V661 V660)) V661) ((AND (CONSP V661) (AND (EQ (QUOTE type) (CAR V661)) (AND (CONSP (CDR V661)) (AND (CONSP (CDR (CDR V661))) (NULL (CDR (CDR (CDR V661)))))))) (shen.kl-to-lisp V660 (CAR (CDR V661)))) ((AND (CONSP V661) (AND (EQ (QUOTE lambda) (CAR V661)) (AND (CONSP (CDR V661)) (AND (CONSP (CDR (CDR V661))) (NULL (CDR (CDR (CDR V661)))))))) (LET ((ChX (shen.ch-T (CAR (CDR V661))))) (CONS (QUOTE FUNCTION) (CONS (CONS (QUOTE LAMBDA) (CONS (CONS ChX ()) (CONS (shen.kl-to-lisp (CONS ChX V660) (SUBST ChX (CAR (CDR V661)) (CAR (CDR (CDR V661))))) ()))) ())))) ((AND (CONSP V661) (AND (EQ (QUOTE let) (CAR V661)) (AND (CONSP (CDR V661)) (AND (CONSP (CDR (CDR V661))) (AND (CONSP (CDR (CDR (CDR V661)))) (NULL (CDR (CDR (CDR (CDR V661)))))))))) (LET ((ChX (shen.ch-T (CAR (CDR V661))))) (CONS (QUOTE LET) (CONS (CONS (CONS ChX (CONS (shen.kl-to-lisp V660 (CAR (CDR (CDR V661)))) ())) ()) (CONS (shen.kl-to-lisp (CONS ChX V660) (SUBST ChX (CAR (CDR V661)) (CAR (CDR (CDR (CDR V661)))))) ()))))) ((AND (CONSP V661) (AND (EQ (QUOTE defun) (CAR V661)) (AND (CONSP (CDR V661)) (AND (CONSP (CDR (CDR V661))) (AND (CONSP (CDR (CDR (CDR V661)))) (NULL (CDR (CDR (CDR (CDR V661)))))))))) (CONS (QUOTE DEFUN) (CONS (CAR (CDR V661)) (CONS (CAR (CDR (CDR V661))) (CONS (shen.kl-to-lisp (CAR (CDR (CDR V661))) (CAR (CDR (CDR (CDR V661))))) ()))))) ((AND (CONSP V661) (EQ (QUOTE cond) (CAR V661))) (CONS (QUOTE COND) (MAPCAR (FUNCTION (LAMBDA (C) (shen.cond_code V660 C))) (CDR V661)))) ((CONSP V661) (LET ((Arguments (MAPCAR (FUNCTION (LAMBDA (Y) (shen.kl-to-lisp V660 Y))) (CDR V661)))) (shen.optimise-application (IF (CONSP (MEMBER (CAR V661) V660)) (CONS (QUOTE shen.apply) (CONS (CAR V661) (CONS (CONS (QUOTE LIST) Arguments) ()))) (IF (CONSP (CAR V661)) (CONS (QUOTE shen.apply) (CONS (shen.kl-to-lisp V660 (CAR V661)) (CONS (CONS (QUOTE LIST) Arguments) ()))) (IF (shen.wrapper (shen.partial-application? (CAR V661) Arguments)) (shen.partially-apply (CAR V661) Arguments) (CONS (shen.maplispsym (CAR V661)) Arguments))))))) ((NULL V661) ()) ((EQ (SYMBOLP V661) (QUOTE T)) (CONS (QUOTE QUOTE) (CONS V661 ()))) (T V661))) 

(DEFUN shen.ch-T (V662) (COND ((EQ T V662) (QUOTE T1957)) (T V662))) 

(DEFUN shen.apply (V175303 V175304)
  (LET ((FSym (shen.maplispsym V175303)))
    (trap-error (shen.apply-help FSym V175304)
                #'(LAMBDA (E)
                    (shen.analyse-application V175303
                                FSym V175304
                               (error-to-string E))))))

(DEFUN shen.apply-help (V175305 V175306)
  (COND ((NULL V175306) (FUNCALL V175305))
        ((AND (CONSP V175306) (NULL (CDR V175306)))
         (FUNCALL V175305 (CAR V175306)))
        ((CONSP V175306)
         (shen.apply-help (FUNCALL V175305 (CAR V175306))
                          (CDR V175306)))
        (T (shen.f_error 'shen.apply-help))))

(DEFUN shen.analyse-application
     (V175307 V175308 V175309 V175310)
  (LET ((Lambda
         (IF (shen.wrapper 
               (shen.partial-application? V175307 V175309))
             (shen.build-up-lambda-expression V175308 V175307)
             (IF (shen.wrapper (shen.lazyboolop? V175307))
                 (shen.build-up-lambda-expression
                                         V175308 V175307)
                 (simple-error V175310)))))
    (shen.curried-apply Lambda V175309)))

(DEFUN shen.build-up-lambda-expression (V175311 V175312)
  (EVAL (shen.mk-lambda V175311 (arity V175312))))

(DEFUN shen.lazyboolop? (F)
  (COND ((EQ F 'and) 'true)
        ((EQ F 'or) 'false)
        (T 'false))) 

(DEFUN shen.curried-apply (V529 V530)
 (COND ((AND (CONSP V530) (NULL (CDR V530))) (FUNCALL V529 (CAR V530)))
  ((CONSP V530) (shen.curried-apply (FUNCALL V529 (CAR V530)) (CDR V530)))
  (T  (simple-error
  (cn "cannot apply "
      (shen.app V529 "
"
                'shen.a))))))
  
(DEFUN shen.partial-application? (V669 V670) (LET ((Arity (trap-error (arity V669) (FUNCTION (LAMBDA (E) -1))))) (IF (shen.ABSEQUAL Arity -1) (QUOTE false) (IF (shen.ABSEQUAL Arity (length V670)) (QUOTE false) (IF (shen.wrapper (shen.greater? (length V670) Arity)) (QUOTE false) (QUOTE true)))))) 

(DEFUN shen.partially-apply (V671 V672) (LET ((Arity (arity V671))) (LET ((Lambda (shen.mk-lambda (CONS (shen.maplispsym V671) ()) Arity))) (shen.build-partial-application Lambda V672)))) 

(DEFUN shen.optimise-application (V673) (COND ((AND (CONSP V673) (AND (EQ (QUOTE hd) (CAR V673)) (AND (CONSP (CDR V673)) (NULL (CDR (CDR V673)))))) (CONS (QUOTE CAR) (CONS (shen.optimise-application (CAR (CDR V673))) ()))) ((AND (CONSP V673) (AND (EQ (QUOTE tl) (CAR V673)) (AND (CONSP (CDR V673)) (NULL (CDR (CDR V673)))))) (CONS (QUOTE CDR) (CONS (shen.optimise-application (CAR (CDR V673))) ()))) ((AND (CONSP V673) (AND (EQ (QUOTE cons) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CDR (CDR V673))) (NULL (CDR (CDR (CDR V673)))))))) (CONS (QUOTE CONS) (CONS (shen.optimise-application (CAR (CDR V673))) (CONS (shen.optimise-application (CAR (CDR (CDR V673)))) ())))) ((AND (CONSP V673) (AND (EQ (QUOTE append) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CDR (CDR V673))) (NULL (CDR (CDR (CDR V673)))))))) (CONS (QUOTE APPEND) (CONS (shen.optimise-application (CAR (CDR V673))) (CONS (shen.optimise-application (CAR (CDR (CDR V673)))) ())))) ((AND (CONSP V673) (AND (EQ (QUOTE reverse) (CAR V673)) (AND (CONSP (CDR V673)) (NULL (CDR (CDR V673)))))) (CONS (QUOTE REVERSE) (CONS (shen.optimise-application (CAR (CDR V673))) ()))) ((AND (CONSP V673) (AND (EQ (QUOTE if) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CDR (CDR V673))) (AND (CONSP (CDR (CDR (CDR V673)))) (NULL (CDR (CDR (CDR (CDR V673)))))))))) (CONS (QUOTE IF) (CONS (shen.wrap (CAR (CDR V673))) (CONS (shen.optimise-application (CAR (CDR (CDR V673)))) (CONS (shen.optimise-application (CAR (CDR (CDR (CDR V673))))) ()))))) ((AND (CONSP V673) (AND (EQ (QUOTE value) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CAR (CDR V673))) (AND (CONSP (CDR (CAR (CDR V673)))) (AND (NULL (CDR (CDR (CAR (CDR V673))))) (AND (NULL (CDR (CDR V673))) (EQ (CAR (CAR (CDR V673))) (QUOTE QUOTE))))))))) (CAR (CDR (CAR (CDR V673))))) ((AND (CONSP V673) (AND (EQ (QUOTE +) (CAR V673)) (AND (CONSP (CDR V673)) (AND (shen.ABSEQUAL 1 (CAR (CDR V673))) (AND (CONSP (CDR (CDR V673))) (NULL (CDR (CDR (CDR V673))))))))) (CONS (intern "1+") (CONS (shen.optimise-application (CAR (CDR (CDR V673)))) ()))) ((AND (CONSP V673) (AND (EQ (QUOTE +) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CDR (CDR V673))) (AND (shen.ABSEQUAL 1 (CAR (CDR (CDR V673)))) (NULL (CDR (CDR (CDR V673))))))))) (CONS (intern "1+") (CONS (shen.optimise-application (CAR (CDR V673))) ()))) ((AND (CONSP V673) (AND (EQ (QUOTE -) (CAR V673)) (AND (CONSP (CDR V673)) (AND (CONSP (CDR (CDR V673))) (AND (shen.ABSEQUAL 1 (CAR (CDR (CDR V673)))) (NULL (CDR (CDR (CDR V673))))))))) (CONS (intern "1-") (CONS (shen.optimise-application (CAR (CDR V673))) ()))) ((CONSP V673) (MAPCAR (QUOTE shen.optimise-application) V673)) (T V673))) 

(DEFUN shen.mk-lambda (V674 V675) (COND ((shen.ABSEQUAL 0 V675) V674) (T (LET ((X (gensym (QUOTE V)))) (CONS (QUOTE lambda) (CONS X (CONS (shen.mk-lambda (shen.endcons V674 X) (1- V675)) ()))))))) 

(DEFUN shen.endcons (V676 V677) (COND ((CONSP V676) (APPEND V676 (CONS V677 ()))) (T (CONS V676 (CONS V677 ()))))) 

(DEFUN shen.build-partial-application (V678 V679) (COND ((NULL V679) V678) ((CONSP V679) (shen.build-partial-application (CONS (QUOTE FUNCALL) (CONS V678 (CONS (CAR V679) ()))) (CDR V679))) (T (shen.f_error (QUOTE shen.build-partial-application))))) 

(DEFUN shen.cond_code (V680 V681) (COND ((AND (CONSP V681) (AND (CONSP (CDR V681)) (NULL (CDR (CDR V681))))) (CONS (shen.lisp_test V680 (CAR V681)) (CONS (shen.kl-to-lisp V680 (CAR (CDR V681))) ()))) (T (shen.f_error (QUOTE shen.cond_code))))) 

(DEFUN shen.lisp_test (V684 V685) (COND ((EQ (QUOTE true) V685) (QUOTE T)) ((AND (CONSP V685) (EQ (QUOTE and) (CAR V685))) (CONS (QUOTE AND) (MAPCAR (FUNCTION (LAMBDA (X) (shen.wrap (shen.kl-to-lisp V684 X)))) (CDR V685)))) (T (shen.wrap (shen.kl-to-lisp V684 V685))))) 

(DEFUN shen.wrap (V1178)
  (COND
   ((AND (CONSP V1178)
         (AND (EQ 'cons? (CAR V1178))
              (AND (CONSP (CDR V1178)) (NULL (CDR (CDR V1178))))))
    (CONS 'CONSP (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'string? (CAR V1178))
              (AND (CONSP (CDR V1178)) (NULL (CDR (CDR V1178))))))
    (CONS 'STRINGP (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'number? (CAR V1178))
              (AND (CONSP (CDR V1178)) (NULL (CDR (CDR V1178))))))
    (CONS 'NUMBERP (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'empty? (CAR V1178))
              (AND (CONSP (CDR V1178)) (NULL (CDR (CDR V1178))))))
    (CONS 'NULL (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'and (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS 'AND
          (CONS (shen.wrap (CAR (CDR V1178)))
                (CONS (shen.wrap (CAR (CDR (CDR V1178)))) NIL))))
   ((AND (CONSP V1178)
         (AND (EQ 'or (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS 'OR
          (CONS (shen.wrap (CAR (CDR V1178)))
                (CONS (shen.wrap (CAR (CDR (CDR V1178)))) NIL))))
   ((AND (CONSP V1178)
         (AND (EQ 'not (CAR V1178))
              (AND (CONSP (CDR V1178)) (NULL (CDR (CDR V1178))))))
    (CONS 'NOT (CONS (shen.wrap (CAR (CDR V1178))) NIL)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (NULL (CAR (CDR (CDR V1178))))
                             (NULL (CDR (CDR (CDR V1178)))))))))
    (CONS 'NULL (CONS (CAR (CDR V1178)) NIL)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (NULL (CAR (CDR V1178)))
                        (AND (CONSP (CDR (CDR V1178)))
                             (NULL (CDR (CDR (CDR V1178)))))))))
    (CONS 'NULL (CDR (CDR V1178))))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (CONSP (CAR (CDR (CDR V1178))))
                             (AND (CONSP (CDR (CAR (CDR (CDR V1178)))))
                                  (AND
                                   (NULL (CDR (CDR (CAR (CDR (CDR V1178))))))
                                   (AND (NULL (CDR (CDR (CDR V1178))))
                                        (AND
                                         (EQ
                                          (SYMBOLP
                                           (CAR (CDR (CAR (CDR (CDR V1178))))))
                                          'T)
                                         (EQ (CAR (CAR (CDR (CDR V1178))))
                                             'QUOTE))))))))))
    (CONS 'EQ (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CAR (CDR V1178)))
                        (AND (CONSP (CDR (CAR (CDR V1178))))
                             (AND (NULL (CDR (CDR (CAR (CDR V1178)))))
                                  (AND (CONSP (CDR (CDR V1178)))
                                       (AND (NULL (CDR (CDR (CDR V1178))))
                                            (AND
                                             (EQ
                                              (SYMBOLP
                                               (CAR (CDR (CAR (CDR V1178)))))
                                              'T)
                                             (EQ (CAR (CAR (CDR V1178)))
                                                 'QUOTE))))))))))
    (CONS 'EQ (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CAR (CDR V1178)))
                        (AND (EQ 'fail (CAR (CAR (CDR V1178))))
                             (AND (NULL (CDR (CAR (CDR V1178))))
                                  (AND (CONSP (CDR (CDR V1178)))
                                       (NULL (CDR (CDR (CDR V1178)))))))))))
    (CONS 'EQ (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (CONSP (CAR (CDR (CDR V1178))))
                             (AND (EQ 'fail (CAR (CAR (CDR (CDR V1178)))))
                                  (AND (NULL (CDR (CAR (CDR (CDR V1178)))))
                                       (NULL (CDR (CDR (CDR V1178)))))))))))
    (CONS 'EQ (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (NULL (CDR (CDR (CDR V1178))))
                             (STRINGP (CAR (CDR V1178))))))))
    (CONS 'EQUAL (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (NULL (CDR (CDR (CDR V1178))))
                             (STRINGP (CAR (CDR (CDR V1178)))))))))
    (CONS 'EQUAL (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (NULL (CDR (CDR (CDR V1178))))
                             (NUMBERP (CAR (CDR (CDR V1178)))))))))
    (CONS 'IF
          (CONS (CONS 'NUMBERP (CONS (CAR (CDR V1178)) NIL))
                (CONS (CONS '= (CDR V1178)) NIL))))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (AND (NULL (CDR (CDR (CDR V1178))))
                             (NUMBERP (CAR (CDR V1178))))))))
    (CONS 'IF
          (CONS (CONS 'NUMBERP (CDR (CDR V1178)))
                (CONS
                 (CONS '=
                       (CONS (CAR (CDR (CDR V1178)))
                             (CONS (CAR (CDR V1178)) NIL)))
                 NIL))))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.equal? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS 'shen.ABSEQUAL (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.greater? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS '> (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.greater-than-or-equal-to? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS '>= (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.less? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS '< (CDR V1178)))
   ((AND (CONSP V1178)
         (AND (EQ 'shen.less-than-or-equal-to? (CAR V1178))
              (AND (CONSP (CDR V1178))
                   (AND (CONSP (CDR (CDR V1178)))
                        (NULL (CDR (CDR (CDR V1178))))))))
    (CONS '<= (CDR V1178)))
   (T (CONS 'shen.wrapper (CONS V1178 NIL)))))

(DEFUN shen.wrapper (V687) (COND ((EQ (QUOTE true) V687) (QUOTE T)) ((EQ (QUOTE false) V687) ()) (T (simple-error (cn "boolean expected: not " (shen.app V687 "
" (QUOTE shen.s))))))) 

(DEFUN shen.maplispsym (V688) (COND ((EQ (QUOTE =) V688) (QUOTE shen.equal?)) ((EQ (QUOTE >) V688) (QUOTE shen.greater?)) ((EQ (QUOTE <) V688) (QUOTE shen.less?)) ((EQ (QUOTE >=) V688) (QUOTE shen.greater-than-or-equal-to?)) ((EQ (QUOTE <=) V688) (QUOTE shen.less-than-or-equal-to?)) ((EQ (QUOTE +) V688) (QUOTE shen.add)) ((EQ (QUOTE -) V688) (QUOTE shen.subtract)) ((EQ (QUOTE /) V688) (QUOTE shen.divide)) ((EQ (QUOTE *) V688) (QUOTE shen.multiply)) (T V688))) 
