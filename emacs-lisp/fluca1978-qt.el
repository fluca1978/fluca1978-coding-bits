;; fluca1978-qt.el

;; A few simple extension to deal with Qt C++ source code.



;; Create a new property, that is a variable with private accessor
;; and with a couple of getter/setter methods
(defun qt-prop (property-name property-type property-comment)
  "Creates a new class property variable with an optional
   comment and with a getter and a setter method at the point where
   the cursor is"
  ;; prompt the user for the data to insert
  (interactive "sProperty name: \nsProperty type (default QObject*): \nsOptional comment for the property: ")
  (progn
    ;; ensure that the property name is correct, that is not an empty
    ;; and remove any space from it. Moreover the property should not include
    ;; any "reference sign" like * or &   
    (while (string-match "[ _\s\t]^*" property-name)
      (setq property-name (replace-match "" nil nil property-name))
      )
    (while (string-match "[ _\s\t\*\&]$*" property-name)
      (setq property-name (replace-match "" nil nil property-name))
      )
    ;; the property should also start with an _ sign
    (if (string-match "[_]^" property-name)
	()
	(setq property-name (concat "_" property-name))
      )

    ;; the type must be specified
    (if (equal "" property-type) 
	(setq property-type "QObject*")
      )

    ;; TODO
    ;; trovare il nome della classe corrente,e da quello costruire i nomi
    ;; dei file header e cpp
    ;; poi andare nella classe in header e trovare il punto di inserimento del
    ;; proprieta' e mettere in fondo al file cpp i metodi di inserimento
    ;; del getter/setter


    (if (equal "_" property-name) 
	;; the user has not specified the property name!
	(message "Cannot insert a not specified property, aborting!")
      ;; if here the user has specified the property name, so
      ;; compute the names of getter/setter
      (let ((setter-name (concat "set" 
				 (capitalize (substring property-name 1 2) )
				 (substring property-name 2) )
			 ) 		; end of the setter-name variable
	    (getter-name  (substring property-name 1) 
			 ) 		; end of the getter-name variable

	    (generate-getter t) 		; do I have to generate the getter?
	    (generate-setter t) 		; do I have to generate the setter?
	    (src-point (point)) 		; where am I?
	    (property-insertion-point (point) ) ; the point where the property will be inserted
	    (property-end-point (point) )	      ; the point where the property ends
	    (generate-property t)
	    (setter-arg-name (concat (capitalize (substring property-name 1 2) )
				 (substring property-name 2) ) )
	    (method-insertion-point (point)) ;where the methods will be inserted
	    (file-name-cpp    nil)			     ; the implementation (.cpp) file name
	    (file-name-header nil)			     ; the header (.h) file name
	    (insert-methods-in-header nil)		     ; true if the getter/setter have to be inserted
					                     ; in the header file
	    (class-name "Luca")				     ; the name of the class the property will be inserted into
	    ) 				; end of the let variable list

	;; remember the current cursor position in the buffer
	(save-excursion
	  (progn

	    ;; I need to check if the getters and setters are already there
	    (goto-char (point-min) )
	    (search-forward "class")		; move to the beginning of the class
	    (if (re-search-forward (concat "[\s \t\n]*void[\s \t\n]*" setter-name "[\s \t\n]*\(.*\)") nil t 1)
		(setq generate-setter nil)
	      (setq generate-setter t)
	      )
	    (goto-char (point-min) )
	    (if (re-search-forward (concat "[\s \t\n]*" property-type "[\s \t\n]*" getter-name "[\s \t\n]*\([\s \t\n]*\)") nil t 1)
		(setq generate-getter nil)
	      (setq generate-getter t)
	      )
	    (goto-char (point-min) )
	    (if (re-search-forward (concat "[\s \t\n]*" property-name) nil t 1)
		(progn
		  (setq generate-property nil)
		  (setq property-insertion-point (point))
		  )
	      (setq generate-property t)
	      )

	    ;; go back to the original position
	    (goto-char src-point)

	    ;; if the getter/setter have to be inserted in the class
	    ;; implementation (i.e., cpp file), their name must have the
	    ;; class qualifier
	    (unless (equal insert-methods-in-header t) 
	      (unless (null class-name)
		(progn
		  (setq getter-name (concat class-name "::" getter-name) )
		  (setq setter-name (concat class-name "::" setter-name) )
		  )
		)
	      )

	    
	    ;; do I have to generate the property?
	    (if generate-property
		(progn
		  (insert ?\n ?\t
			  "/**" ?\n
			  " * " property-comment ?\n
			  "*/" ?\n
			  property-type " " property-name ";" ?\n
			  getter-name
			  ?\n ?\n
			  )			; end of the insert for the property
		  (setq property-end-point (point) ) ; store where the property ends
		  ;; indent the property region
		  (c-indent-region property-insertion-point property-end-point t)


		  ;; go to the end of the buffer and position before the last
		  ;; curly brace that should close the class
		  (goto-char (point-max))		; goto end of buffer
		  (re-search-backward "}")		; go back to the last }
		  (setq method-insertion-point (point) ) ; store where the methods will be added
		  
		  (if generate-getter 

		      (insert ?\n ?\t
			      "/**" ?\n
			      "* Getter for the property " property-name "." ?\n
			      "* \\returns the current value of the property " property-name ?\n
			      "*" ?\n
			      "* \\author " user-full-name " - " user-mail-address ?\n
			      "*/" ?\n
			      property-type ?\n getter-name "(){"
			      ?\n ?\t 
			      "return this->" property-name ";"
			      ?\n ?\t
			      "}"
			      ?\n ?\n ?\n
			      )		; end of the insert for the getter
		    (message "Skipping the generation of the getter method")
		    )			; end of the if for the getter method
		  (if generate-setter
		      
		      (insert
		       ?\n ?\t 
		       "/**" ?\n
		       "* Setter of the property " property-name "." ?\n
		       "* \\param " setter-arg-name " the new value for the property" ?\n 
		       "*" ?\n
		       "* \\author " user-full-name " - " user-mail-address ?\n
		       "*/" ?\n
		       "void" ?\n setter-name "( " property-type " " setter-arg-name " ){"
		       ?\n ?\t 
		       "this->" property-name " = " setter-arg-name ";" 
		       ?\n ?\t
		       "}"
		       ?\n ?\n ?\n
		       )			; end of the insert body for the setter method
		    (message "Skipping the generation of the setter method")
		    )				; end of the if for the setter method
		  

		  ;; indent the region for the methods
		  (c-indent-region method-insertion-point (point) t)

		  ) 				; end of the progn on the generation of the property

	      (message "Cannot generate the property [%s], it already exists at line %d" 
		       property-name 
		       (count-lines 1 property-insertion-point ) )
	      )				; end of the if for the property generation
	    

	    ) 					; end of progn within save excursion
	  )					; end of the save-escurion
	)						; end of the let main body

      )					;end of the if on the property name
    )					; end of the progn
  )				;end of defun
