(DEFUN simple-error (String) (ERROR "~A" String))
(COMPILE 'simple-error)
(SETQ shen.*history* NIL)
(EXT:SAVEINITMEM "NewShen.mem" :INIT-FUNCTION 'shen.byteloop)