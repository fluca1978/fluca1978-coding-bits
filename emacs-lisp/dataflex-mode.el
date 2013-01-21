


;;  Mode hook, so that users can customize the mode.
;;  At the beginning this hook does not contain anything, that is
;;  no customization is set up.
(defvar dataflex-mode-hook nil 
  "Dataflex mode hook to allow user customization" )


;;  Define a keymap to specify key bindings.
;;
;; The df-map variable will hold the keybindings and is initially
;; initialized by the make-keymap function.
;; Then each new key is defined via the define-key function and is associated
;; to the df-map variable, which is in turn returned by the let statement and therefore
;; is assigned to the dataflex-mode-map.
(defvar dataflex-mode-map
  (let ( (df-map (make-keymap) ) )
    (define-key df-map "\C-j"         'newline-and-indent)
    (define-key df-map "\C-c\C-t"     'df-transpose-single-line-move)
    (define-key df-map "\C-C\C-i"     'dataflex-mode-indent-back-from-here)
    df-map )
  "Keyboard map for the Dataflex Mode" )

;;  Add to the auto-load-alist this mode, so that each time that Emacs is visiting
;;  .frm or .mac files this mode will be used.
(add-to-list 'auto-mode-alist '( "\\.frm$" . dataflex-mode ) )
(add-to-list 'auto-mode-alist '( "\\.mac$" . dataflex-mode ) )


;;  To generate an optimized (and therefore less resource consuming) regexp use the regexp-opt
;;  function from the Elisp Shell (M-x eshell) as follows:
;;  (regexp-opt '( "IF" "THEN" "ELSE" "BEGIN" "END" "WHILE" "LOOP" "FOR" "NAME" "MOVE" "TO" "OPEN" "CLOSE" "SAVERECORD" "UNLOCK" ) t)
;;  which produces the following regexp:
;; \(BEGIN\|CLOSE\|E\(?:LSE\|ND\)\|FOR\|IF\|LOOP\|MOVE\|NAME\|OPEN\|SAVERECORD\|T\(?:HEN\|O\)\|UNLOCK\|WHILE\)
;;  then wrap the regexp with < and > to match a complete word (e.g. avoid ENDED to be emphasized by END).
;;  
;;  Use the font-lock-variable-name-face for each simple word and the font-lock-builtin-face for special keywords.
;;  Define a constant for the main syntax hightlighting.
(defconst dataflex-font-lock-keywords-minimal
  (list
   '("\\<\\(BEGIN\\|E\\(?:LSE\\|ND\\)\\|FOR\\|IF\\|LOOP\\|MOVE\\|||T\\(?:HEN\\|O\\)\\|WHILE\\)\\>" . font-lock-builtin-face )
   '("\\('\\w*'\\)" . font-lock-variable-name-face) )
  "Main (and minimal) highlighting for the Dataflex mode keywords" )

(defconst dataflex-font-lock-keywords-main
  (append dataflex-font-lock-keywords-minimal 
	  (list
	   '("\\<\\(NAME\\|OPEN\\|SAVERECORD\\UNLOCK\\|CLOSE\\|GOTO\\|RETURN\\)\\>" . font-lock-constant-face ) ) )
  "Full keyword list" )
	   

;;  Now define the whole highlights.
;;
(defvar dataflex-font-lock-keywords dataflex-font-lock-keywords-main
  "Default and full hightlighting for the Dataflex Mode" )


(defvar dataflex-mode-syntax-table
  (let ( (df-syn-table (make-syntax-table)) )
    (modify-syntax-entry ?_ "w" df-syn-table)           ; two words with a single _ are seen as one	        ;;
    (modify-syntax-entry ?/ ". 12b" df-syn-table)      ; c++-like comment with //			        ;;
    (modify-syntax-entry ?\n "> b" df-syn-table)	; end of c++-like comment by newline		        ;;
    df-syn-table )
  "Syntax table for the Dataflex mode" )





;;  A function to wrap comment-dwin so that it is possible to comment in/out a whole region.
;;  This function will use 'newcomment and use the // as a comment begin mark and nothing as
;;  a comment end.
(defun dataflex-comment-dwim (arg)
  "Comment (in/out) a Dataflex piece of source code. 
It is based on comment-dwin of newcomment.el"
  (interactive "*P")
  (require 'newcomment)
  (let ( (comment-start "// * ") (comment-end " *** ") (comment-style 'box) )
    (comment-dwim arg)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun df-transpose-single-line-move ()
  "Transposes a MOVE A TO B instruction into a MOVE B TO A one"
  (interactive)
    (progn
      (beginning-of-line)	       ; go to the begin of the line
      (forward-word)		       ; skip after MOVE
      (forward-word)		       ; skip after A
      (forward-word)		       ; skip after TO
      (transpose-words 1)		; transpose TO and B
      (backward-word)			
      (backward-word)			; move at A
      (transpose-words 1)		; transpose B and A
      (transpose-words 1)		; transpose A and TO
      (end-of-line)
      (forward-line 1)			; go to the next line
      ) ) 




;;  This variable defines the indent space size.
(defvar dataflex-mode-indent-step 4 
  "The number of spaces for each indent level" )

(defun dataflex-mode-indent-back-from-here ()
  "A function to indent to a single level all the code from this line (current one) assuming 
the line is one of that closes a block (e.g., an END)"
  (interactive)												        
				       
  (beginning-of-line)  														        ;;
  ;;  at the beginning of the buffer the indentation is always zero						        ;;
  (if (bobp) 												        ;;
      (indent-line-to 0) )											        ;;
  ; else													        ;;
  (let ( (line-begin-block nil) (line-end-block nil) (current-line-indent-step dataflex-mode-indent-step) )	        ;;
    (if (looking-at "^[ \t]*\\(RETURN\\|END\\|ABORT\\)[\s \t\n]*$")	; found an explicit END or RETURN
	  (save-excursion											        ;;
	    ;;  store this line as the one that marks the end of a block					        ;;
	    (setq line-end-block (1+ (count-lines 1 (point) ) ) )						        ;;
														        ;;
	    ;;  go back one line at time to find the line that opens a block					        ;;
	    ;;  and store the number of the line that ends the current block					        ;;
	    (while (null line-begin-block)									        ;;
	      (forward-line -1)		; go to the previous line						        ;;
	      (if (bobp)
		  (setq line-begin-block 1))
	      (if (looking-at "^[ \t]*\\(IF\\|WHILE\\|BEGIN\\|LOOP\\)" )									        ;;
		  (progn											        ;;
		    ;;  this is the line that opens a block
		    ;;  indentation of the BEGIN block line							        ;;
		    (setq current-line-indent-step (current-indentation) )					        ;;
		    ; go to the very next line (the one that needs to be indented)
		    (forward-line 1)
		    (setq line-begin-block (1+ (count-lines 1 (point) ) ) )					        ;;
		    ;;  compute how much the following lines have to be indented				        ;;
		    (setq current-line-indent-step (+ current-line-indent-step dataflex-mode-indent-step))	        ;;
														        ;;
		    )))												        ;;
							


	    (while (< line-begin-block line-end-block)								        ;;
	      (progn												        ;;
		(setq line-begin-block (1+ line-begin-block) )
		(indent-line-to current-line-indent-step) 
		(forward-line 1) ) ) 

))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;  Mode entry function.
;;  This function is called each time Emacs enters this mode.
(defun dataflex-mode ()
  "Major mode for editing Dataflex related source files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table dataflex-mode-syntax-table) ; set the mode syntax table
  (use-local-map dataflex-mode-map )		; set the keyboard map

  ;;  keywords for the mode
  ;;  (the third argument makes the font-locking case insensitive so that both uppercase and
  ;;  lower case keywords are emphasized)
  (set (make-local-variable 'font-lock-defaults) '(dataflex-font-lock-keywords nil t) )

  ;;  set the mode info
  (setq major-mode 'dataflex-mode)
  (setq mode-name "DATAFLEX")
  ;;  run all the hooks for this mode (enable customization)
  (run-hooks 'dataflex-mode-hook) )


;;  Provide this mode 
(provide 'dataflex-mode)
