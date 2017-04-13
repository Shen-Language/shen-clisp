\*

Copyright (c) 2010-2015, Mark Tarver

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
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*\

\\ Plaform interop package for CLisp

(package lisp []

  (defmacro platform-macro
     F -> (if (symbol? F)
              (let Str (str F)
                   (if (lisp-call? Str)
                       [protect (intern (call-lisp Str))]
                       F))
              F))

  (define lisp-call?
    (@s ($ lisp.) _) -> true
    _ -> false)

  (define call-lisp
    (@s ($ lisp.) S) -> (uppercase S))

  (define uppercase
    "" -> ""
    (@s "." Ss) -> (@s ":" (uppercase Ss))
    (@s S Ss) -> (@s (uppercase-letter S) (uppercase Ss)))

  (define uppercase-letter
     S -> (let ASCII (string->n S)
               (if (and (>= ASCII 97) (<= ASCII 122))
                   (n->string (- ASCII 32))
                   S))))
