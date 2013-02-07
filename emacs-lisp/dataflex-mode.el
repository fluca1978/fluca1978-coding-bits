;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  DATAFLEX MODE
;;  An Emacs Major Mode for developing Dataflex Based applications.
;;  
;;  Author: Luca Ferrari fluca1978 (at) gmail (dot) com
;;  
;;  This mode provides a set of font-locking and utility functions to ease the development of
;;  dataflex source code files (usually .frm and .mac). The mode installs its own keymap
;;  so that the following commands are available:
;;  
;;  C-j => usual new line and indent Emacs feature
;;  C-c C-t => transposes a single line or a whole region so that assignments are reverted. In
;;  other words a MOVE A TO B becomes MOVE B TO A.
;;  C-c C-i => indent the current region or the whole buffer
;;  C-c C-j => jump to a label within the same buffer: splits the window if the label
;;  is not visible and sets the cursor at such label.
;;  
;;  In order to load automatically this mode for Dataflex source files add the following
;;  lines to your .emacs configuration file:
;;  
;;  (add-to-list 'load-path "~/.emacs.d/" )
;;  (require 'dataflex-mode)		
;;   
;;  assuming, of course, you have installed the file into your $HOME/.emacs.d
;;  directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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
    (define-key df-map "\C-c\C-t"     'dataflex-transpose-single-line-or-region)
    (define-key df-map "\C-c\C-i"     'dataflex-indent-region-or-buffer )
    (define-key df-map "\C-c\C-j"     'dataflex-jump-to-label )
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
   '("\\<\\(BEGIN\\|E\\(?:LSE\\|ND\\)\\|FOR\\|IF\\|LOOP\\|MOVE\\|TO\\|WHILE\\|NOT\\)\\>" . font-lock-constant-face )
   '("\\('\\w*'\\)" . font-lock-variable-name-face) )
  "Main (and minimal) highlighting for the Dataflex mode keywords" )

(defconst dataflex-font-lock-keywords-builtin
  (append dataflex-font-lock-keywords-minimal 
	  (list
	   '("\\<\\(NAME\\|OPEN\\|SAVERECORD\\UNLOCK\\|CLOSE\\|GOTO\\|RETURN\\|INCLUDE\\)\\>" . font-lock-builtin-face ) ) )
  "Full keyword list" )
	   
;;  Append the mask specific font-locks. 
(defconst dataflex-font-lock-keywords-main
  (append dataflex-font-lock-keywords-builtin
	  (list
	   '("[^a-zA-Z0-9 \t][_\\.]+[^a-zA-Z0-9 \t]" . font-lock-doc-face) 
	   '("^/\\*[ \t]*$" . font-lock-warning-face)
	   '("[ \t]*\[[ \t]*\\w+[ \t]*\\w*[ \t]*\]" . font-lock-warning-face)
	   '("^/\\w+[ \t]*$" . font-lock-warning-face) ) )
  "Mask(s) font locking" )


;;  Now define the whole highlights.
;;
(defvar dataflex-font-lock-keywords dataflex-font-lock-keywords-main
  "Default and full hightlighting for the Dataflex Mode" )


(defvar dataflex-mode-syntax-table
  (let ( (df-syn-table (make-syntax-table)) )
    (modify-syntax-entry ?_ "w" df-syn-table)           ; two words with a single _ are seen as one	        ;;
    (modify-syntax-entry ?. "w" df-syn-table)           ; two words with a single . are seen as one	        ;;
    (modify-syntax-entry ?/ ". 12b" df-syn-table)      ; c++-like comment with //			        ;;
    (modify-syntax-entry ?\n "> b" df-syn-table)	; end of c++-like comment by newline		        ;;
    df-syn-table )
  "Syntax table for the Dataflex mode" )






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun dataflex-transpose-single-line-or-region ()
  "A function to transpose instruction(s) in the form of

         MOVE A TO B
  
   into something like

        MOVE B TO A

  This function can work on a single line or a whole region. Each line must be a
  complete MOVE A TO B command, or the line will be skipped. "
  (interactive)

  (let ( (current-start-line (line-number-at-pos (point) ) ) (current-end-line (line-number-at-pos (point) ) ) )
    (if (use-region-p)
	;;  using a region...
	(setq current-start-line (line-number-at-pos (region-beginning) )
	      current-end-line   (line-number-at-pos (region-end) ) ) )

    ;;  iterate over each line and transpose if needed
    (while (<= current-start-line current-end-line )
      (progn
	(goto-line current-start-line)
	(beginning-of-line)
	(if (looking-at "^[ \t]*\\(MOVE\\)[ \t]+\\(.+\\)[ \t]+\\(TO\\)[ \t]+\\(.+\\)$")
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
	      (end-of-line) )
	  ;;  else...cannot do a transpose
	  (message "Not a (complete) MOVE instruction: it must be in the form MOVE A TO B") )
	
	;;  advance one line
	(setq current-start-line (1+ current-start-line) )
	(forward-line 1) ) ) ) )
    
    
      
      


;;  This variable defines the indent space size.
(defvar dataflex-mode-indent-step 4 
  "The number of spaces for each indent level" )

(defvar dataflex-mode-indent-step-labels 2
  "The number of spaces for each indent level for labels" )

;;  A function to indent a whole buffer or the active region.
(defun dataflex-indent-region-or-buffer ()
"This function indents the whole buffer or, in the case a region is active, the active region."
  (interactive)
  
  (let ( (current-block-end-pos 0 ) (current-block-start-pos 0) (current-indentation-step 0) (next-line-indentation-step 0) ) 
    (progn


      ;;  if using a region indent only such region, otherwise the whole buffer
      (if (use-region-p)
	  ;;  using a region...
	  (setq current-block-start-pos (region-beginning) 
		current-block-end-pos   (region-end) )
	;;  ...else use the whole buffer
	  (setq current-block-start-pos (point-min) 
		current-block-end-pos   (point-max) ) )
      
	  

      ;;  go to the starting line
      (goto-char current-block-start-pos)

      ;;  go to the beginning of the line
      (beginning-of-line)

    (while (<= current-block-start-pos current-block-end-pos )
      (if (looking-at "^[ \t]*\\(IF\\|WHILE\\|BEGIN\\|LOOP\\)") 
	  ;; the BEGIN line has to be indented at the current level, and the next
	  ;;  line at a deeper level
	  (setq next-line-indentation-step (+ current-indentation-step dataflex-mode-indent-step) )
	;;   else if looking at an END line remove the indentation
	(if (looking-at "^[ \t]*\\(END\\|RETURN\\|ABORT\\)") 
	    (progn
	      (setq current-indentation-step (- current-indentation-step dataflex-mode-indent-step) )
	      (setq next-line-indentation-step current-indentation-step ) )
	  ;;  else if this is a label line reset the indentation
	  (if (looking-at  "^[ \t]*\\(.+\\):[ \t\n]*")
	      (setq current-indentation-step 0 next-line-indentation-step dataflex-mode-indent-step-labels) ) ) )
	    

      ;;  security check: do not indent at negative offset
      (if (< current-indentation-step 0 )
	  (setq current-indentation-step 0) )
      (if (< next-line-indentation-step 0 )
	  (setq next-line-indentation-step 0 ) )

      ;;  do the indent of the current line and go forward
      (indent-line-to current-indentation-step)
      (setq current-indentation-step next-line-indentation-step)
      (forward-line 1)
      (setq current-block-start-pos (point) ) ) ) ) )
	  
	    

      

;;  A function to indent a block of lines of the specified amount of spaces.
(defun dataflex-indent-lines ( line-begin-block line-end-block current-indent-step  ) 
  "Performs an indentation of the specified buffer lines with the specified amount of space.
If doing a recursive indentation also indent the last line of the block.

Arguments are:

line-begin-block
is the first line to start indentation from

line-end-block
is the last line to end indentation

current-indent-step
is the number of spaces to indent each line

"
  (interactive "nFrom line: \nnTo line: \nnHow much indentation: ")

  (save-excursion
    ;;  check arguments:
    ;;  the line-begin-block must be at least 0 (first line of the buffer)
    ;;  and the line-end-block must be greater than the line-begin-block.
    ;;  Moreover, the indentation step must be greater than zero, or it is
    ;;  set to the default value.
    (if (< line-begin-block 0 )
	(setq line-begin-block 0)
      (if (< line-end-block line-begin-block)
	  (setq line-end-block line-begin-block ) ) )

    (if (< current-indent-step 0 )
	(setq current-indent-step dataflex-mode-indent-step ))

    ;;  start from the first line
    (goto-line line-begin-block)
    
    ;;  loop thru the lines to indent each line
    (while (<= line-begin-block line-end-block)								        ;;
      (progn												        ;;
	(setq line-begin-block (1+ line-begin-block) )
	(indent-line-to current-indent-step) 
	(forward-line 1) ) ) ) )
  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun dataflex-jump-to-label ( label-to-jump-to )
  "A function to jump to a specific label (e.g., LABEL:). The function asks the user
to specify the label to jump to or, in the case the user does not specify it, jumps to
the current word label (if any)."
  (interactive "sLabel to jump (within the buffer): ")
  (progn
    (if (<= (length label-to-jump-to) 0)
	(setq label-to-jump-to (thing-at-point 'symbol) ) )
      
    (if (or (null label-to-jump-to) (<= (length label-to-jump-to) 0) )
	(message "No label specified!")
      ;;  else search the label
      
      (let ( ( label-regexp (concat "^[ \t]*" label-to-jump-to ":") ) 
	     (original-pos (point) )	; I need to save the original point the user is
	     (label-line 0) 
	     (label-pos 0)
	     (label-window nil) )
	;;  go to the beginning of the buffer
	(beginning-of-buffer)
	;;  search the label forward
	(if (re-search-forward label-regexp)
	    (progn
	      ;;  the label has been found
	      (setq label-pos (point) )
	      (setq label-line (line-number-at-pos (point) ) )
	      (goto-char original-pos)
	      ;;  open a window and jump to the specified label
	      (if (null (pos-visible-in-window-p label-pos (selected-window) ) )
		  (progn
		    (setq label-window (split-window-below) )
		    (select-window label-window)
		    (goto-line  label-line)  )
		;;  else show the user that the label is visible
		(message (format "The label is visible on line %d (position %d)!" label-line label-pos) ) ) )
	  ;;  else cannot find the label in the buffer!
	  (message (format "Cannot find the label [%s] (searched with [%s]) in this buffer!" label-to-jump-to label-regexp) ) ) ) ) ) )
    




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

  ;;  comments
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-start-skip) "//+\\s-*")

  ;;  set the mode info
  (setq major-mode 'dataflex-mode)
  (setq mode-name "DATAFLEX")
  ;;  run all the hooks for this mode (enable customization)
  (run-hooks 'dataflex-mode-hook) )


;;  Provide this mode 
(provide 'dataflex-mode)
