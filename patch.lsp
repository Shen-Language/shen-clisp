(DEFUN simple-error (String) (ERROR "~A" String))
(COMPILE 'simple-error)
(SETQ shen.*history* NIL)
(EXT:SAVEINITMEM "shen.patched.mem" :INIT-FUNCTION 'shen.byteloop)
