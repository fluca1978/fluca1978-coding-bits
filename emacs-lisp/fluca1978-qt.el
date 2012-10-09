;; fluca1978-qt.el

;; A few simple extension to deal with Qt C++ source code.


;; A regexp used to find where a class declaration starts in an header file.
(defvar regexp-class-declaration "class[ \t\s\n]+\\(\\w+\\)[ \t\s\n]*\\(.*\\)[ \t\s\n]*[{]$")

;; regular expression to find and match the include start and end
(defvar regexp-include-start "[ \t\s]*#include[ \t\s]+[\"<]+")
(defvar regexp-include-end   "[\">]+")


;; Create a new property, that is a variable with private accessor
;; and with a couple of getter/setter methods
(defun qt-prop (property-name property-type property-comment)
  "Creates a new class property variable with an optional
   comment and with a getter and a setter method at the point where
   the cursor is"
  ;; prompt the user for the data to insert
  (interactive "sProperty name: \nsProperty type (default QObject*): \nsOptional comment for the property: ")
  (progn

    ;; compute the field name (prefix it with a _)
    (setq property-name (qt-field-name property-name))

    
    ;; the type must be specified
    (setq property-type (qt-field-type property-type))


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
	    (class-name nil)				     ; the name of the class the property will be inserted into
	    (generate-private-section nil)		     ; do I have to generate the private section in the class definition?
	    (generate-public-section  nil)		     ; do I have to generate the public section?
	    (visiting-buffer-filename nil)		     ; the buffer the user has invoked this function onto
	    (visiting-point           nil)		     ; where the user was editing
	    (class-beginning-point    nil)		     ; where the class starts in the header
	    (setter-regexp-signature  nil)		     ; the signature of a setter method
	    (getter-regexp-signature  nil)		     ; the signature of a getter method
	    (property-regexp-signature nil)		     ; the regexp for the property declaration
	    ) 				; end of the let variable list

	;; remember the current cursor position in the buffer
	(save-excursion
	  (progn



	    ;; I need to try to understand what kind of buffer I am visiting:
	    ;; if it is an header file, than it must contain the class declaration
	    (setq visiting-buffer-filename (buffer-file-name) )
	    (if (string-match "[.]*h[pp]*" (file-name-extension visiting-buffer-filename) )
		;; on the header file, so search for the class name
		(progn
		  (setq visiting-point (point))
		  (goto-char (point-min))
		  (setq insert-methods-in-header t) ; insert the methods into the header

		  (setq class-name (qt-find-class-name (buffer-name)) )

		  
		  ;; the user is editing the header file, so I guess
		  ;; she wants to insert the getter/setter into the header file
		  ;; itself
		  (setq insert-methods-in-header t)
		  (setq class-beginning-point (point))
		  
		  
		  
		  
		  ;; insert the property in the header file
		  (qt-insert-property-in-header-buffer (buffer-name)
						       property-name
						       property-type
						       property-comment
						       )
		    

		  
	      

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


	    ;; build the regexp signature for the getter and setter methods
	    (setq getter-regexp-signature (concat "[ \s\n\t]*" property-type "[ \s\n\t]+" getter-name "[ \s\n\t]*([ \s\n\t]*)" ) )
	    (setq setter-regexp-signature (concat "[ \s\n\t]*void[ \s\n\t]+" setter-name "[ \s\n\t]*([ \s\n\t]*" property-type "[ \s\n\t]+\\(\\w+\\)[ \s\n\t]*)" ) )
	    




	    ;; now see if I need to generate the methods into the header file
	    (unless (null insert-methods-in-header)
	      (progn
		
		;; does the header include a public section?
		;; assume that the getter/setter method position will be
		;; right after the public section
		(goto-char class-beginning-point)
		(if (re-search-forward "[\s \t\n]*public:[\s \t\n]*" nil t 1)
		    (progn
		      (setq generate-public-section nil)
		      (setq method-insertion-point (point))
		      )
		  (progn
		    (setq generate-public-section t)
		    (goto-char (point-max))
		    (search-backward "}")
		    (setq method-insertion-point (point))
		    )
		  )


		;; search for the getter/setter
		(goto-char method-insertion-point)
		(if (re-search-forward getter-regexp-signature nil t 1 )
		    (setq generate-getter nil)
		  (setq generate-getter t)
		  )
		(goto-char method-insertion-point)
		(if (re-search-forward setter-regexp-signature nil t 1 )
		    (setq generate-setter nil)
		  (setq generate-setter t)
		  )
				       
				      
		

		(goto-char method-insertion-point)

		;;  do I have to generate the public section?
		(if (equal generate-public-section t)
		    (insert ?\t "public:" ?\n)
		  )

		;; place the getter
		(unless (null generate-getter)
		  (qt-insert-accessor method-insertion-point property-name property-type t)
		  )
		
		;; place the setter
		(unless (null generate-setter)
		  (qt-insert-accessor (point) property-name property-type nil)
		  )

		)	      ; end of progn
	      )				; end of unless insert methods in header

	      )
	    )					; end of the case on the header file
	    )						; end of the progn
	  )						; end of save-excursion
	)					; end of let
	
      
      )					; end of the if on the property name
    )					; end of the main progn
  )					; end of the function




;; A function to insert a getter/setter method at a specific point in the buffer.
;; The property name will be cut off the first character, that is supposed to be
;; a "_"; the is-getter is set to true to generate a getter method, nil to generate
;; a setter method.
;;
;; The following calls are examples:
;;
;; (qt-insert-accessor (point) "_myProperty" "QObject*" t)
;; (qt-insert-accessor (point) "_myProperty" "QObject*" nil)
;;
;;
(defun qt-insert-accessor (method-insertion-point property-name property-type is-getter )

  (let (
	(setter-arg-name (substring property-name 1))
	)
      (if (equal is-getter t)
	  (progn
	    (goto-char method-insertion-point)

	    ;; place the getter
	    (insert ?\n ?\t
		    "/**" ?\n
		    "* Getter for the property " property-name "." ?\n
		    "* \\returns the current value of the property " property-name ?\n
		    "*" ?\n
		    "* \\author " user-full-name " - " user-mail-address ?\n
		    "*/" ?\n
		    property-type ?\n getter-name "()"
		    ?\n ?\t 
		    "{" ?\n ?\t
		    "return this->" property-name ";"
		    ?\n ?\t
		    "}"
		    ?\n ?\n ?\n
		    )		; end of the insert for the getter
	    )
	(progn
	  (goto-char method-insertion-point)
	  
	  (insert
	   ?\n ?\t 
	   "/**" ?\n
	   "* Setter of the property " property-name "." ?\n
	   "* \\param " setter-arg-name " the new value for the property" ?\n 
	   "*" ?\n
	   "* \\author " user-full-name " - " user-mail-address ?\n
	   "*/" ?\n
	   "void" ?\n setter-name "( " property-type " " setter-arg-name " )"
	   ?\n ?\t 
	   "{" ?\n ?\t
	   "this->" property-name " = " setter-arg-name ";" 
	   ?\n ?\t
	   "}"
	   ?\n ?\n ?\n
	   )			; end of the insert body for the setter method
	  
	  )				; end of the else case (setter genration)
	)				; end of the if on the type of method
    
      ;; indent the region where the methods have been defined
      (c-indent-region method-insertion-point (point) t)
      

    
    


    )  				; end of the let body
  
)




;; A method to insert the property into the header file/buffer.
;; The method accepts the name of a buffer that is visiting the header file, as well as the property
;; name and type (and comment) and a point to where insert the property into the class declaration.
(defun qt-insert-property-in-header-buffer (header-buffer-name property-name property-type property-comment)

  (let (  (property-regexp-signature nil)
	  (generate-private-section  nil)
	  (property-insertion-point  nil)
	  (source-point              (point))
	  (generate-property         nil)
	  (property-end-point        nil)
	  (class-beginning-point     nil)
	  (include-insert-point      (point-min))
	  (generate-include          nil)
	  )
    (progn

      ;; find the class beginning point
      (setq class-beginning-point (qt-class-beginning-point header-buffer-name) )


      ;; go to the header buffer
      (switch-to-buffer header-buffer-name)
      ;; the regexp for the property sitgnature
      (setq property-regexp-signature (concat "[\s \t\n]*"  property-name) )
      ;; move to the beginning of the class
      (goto-char class-beginning-point)
      ;; search for the private section
      (if (re-search-forward "[\s \t\n]*private:[\s \t\n]*" nil t 1)
	  (progn
	    (setq generate-private-section nil)
	    (setq property-insertion-point (point))
	    )
	
	(progn
	  (setq generate-private-section t)
	  (setq property-insertion-point class-beginning-point)
	  )
	)


      ;; Check if I have also to generate the header for the property type
      ;; (qt-guess-include property-type) ?\n
      (goto-char (point-min))
      (if (re-search-forward (concat regexp-include-start (qt-guess-include property-type)  regexp-include-end) nil t 1  )
	  (setq generate-include nil)
	(setq generate-include t)
	)

      



      ;; I need to check if the property has been already defined in the
      ;; header file (under the private section)

      (goto-char class-beginning-point)	; move to the beginning of the class
      (if (re-search-forward property-regexp-signature nil t 1)
	  (progn
	    (goto-char (point-max) )
	    (search-backward "}")
	    (setq generate-property nil)
	    (setq property-insertion-point (point))
	    )
	(setq generate-property t)
	)


      ;; do I have to generate the property?
      (unless (null generate-property )
	(progn


      ;; do I have to generate the include?
	  (setq include-insertion-point (qt-find-include-insertion-point class-beginning-point ) )
	  (unless (null generate-include)
	    (goto-char include-insertion-point)
	    (insert ?\n
		    "#include <" (qt-guess-include property-type) ">"
		    ?\t "/* guessed for the property " property-name " */"
		    ?\n
		    )
	    
	    ;; compute the offset of the other variables (since I have inserted the include
	    ;; the class and property starting points have changed)
	    (setq class-beginning-point (+ class-beginning-point (- (point) include-insertion-point ) ) )
	    (setq property-insertion-point (+ property-insertion-point (- (point) include-insertion-point ) ) )
	    
	    
	    )				; end of include generation


	  ;;  first of all go to where the property has to be placed
	  (goto-char property-insertion-point)

	  ;;  do I have to generate the private section? If so go to the end
	  ;;  of the class to avoid making privates variable
	  (if generate-private-section 
	      (progn			
		(insert ?\n ?\t "private:" ?\n)
		)
	    )
	  
	  (insert ?\n ?\t
		  "/**" ?\n
		  " * " property-comment ?\n
		  "*/" ?\n
		  property-type " " property-name ";" ?\n
		  ?\n ?\n
		  )			; end of the insert for the property
	  (setq property-end-point (point) ) ; store where the property ends
	  ;; indent the property region
	  (c-indent-region property-insertion-point property-end-point t)
	  ;; here the property has been inserted in the header file/buffer, save it
	  (save-buffer)
	  )

	)
      )
    )
  )







;; A function to extract the class name from the header file (or nil if the class
;; is not found).
(defun qt-find-class-name (header-buffer-name)
  (let ()
    (progn
      ;;  go to the buffer that contains the header file
      (switch-to-buffer header-buffer-name)
      (goto-char (point-min))
      ;; search for the class
      (if (re-search-forward regexp-class-declaration)
	  (match-string 1)
	nil
	)
      )
    
    )					; end of let
  )					; end of defun




;; A function to get the class beginning point in the header file.
;; Returns the point of the class declaration or nil.
(defun qt-class-beginning-point (header-buffer-name)
  (let ()
    (progn
      ;;  go to the buffer that contains the header file
      (switch-to-buffer header-buffer-name)
      (goto-char (point-min))
      ;; search for the class
      (if (re-search-forward regexp-class-declaration)
	  (point)
	nil
	)
      )
    
    )
  )
					;end of defun


;; A function to compute and clear the property name, that is removing any
;; strange symbol like a reference sign. The property name is then
;; prefixed with a "_" sign.
(defun qt-field-name (property-name)
  (let ()
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

    ;; return the computed property name
    property-name
    
    )					; end of let body
)					; end of defun

;; Checks and returns the right property type.
;; If the property type is empty or nil the default QObject* is used, otherwise
;; the specified property type is returned
(defun qt-field-type (property-type)
  (let ()
    (if (or (null property-type) (equal "" property-type))
	"QObject*"
      property-type
      )
    )					; end of let
)					;end of defun


;; Try to guess the include file from the property file.
(defun qt-guess-include (property-type)
  (let ((include-file nil))

    ;; clear the property type

    ;; does the property type include a template pattern?
    ;; (e.g., QList<QObject*>)
    (if (string-match "\\(\\w+\\)\\([<\\w+>]*\\)" property-type)
	(setq property-type (match-string 1 property-type) )
      )


    ;; does the property type include a reference or pointer?
    ;; (e.g., QObject* or QObject&)
    (if (string-match "[\*\&]?$" property-type)
	(setq property-type (replace-match "" nil nil property-type))
      )					; end of if 

    ;; the include should be the property found. By default, if the
    ;; property type is a Qclass do not append the .h suffix.
    (if (string-match "[Q].+" property-type)
	(setq  include-file property-type)
      (setq include-file (concat property-type ".h") )
      )
	    
    ;; return the include
    include-file

    )					; end of let body
)					; end of defun



;; A function to find the last position at the end of the include list (if any)
;; so that the include can be inserted in such position.
(defun qt-find-include-insertion-point (class-beginning-point)
  (let ((include-insertion-point (point-min)))
	
	;; search for all the includes and find the last
    (goto-char include-insertion-point)
    (while (re-search-forward regexp-include-start class-beginning-point t nil)
      (setq include-insertion-point (point))
      )				; end of while
    
    ;; return the point where the include will be appended
    ;; goto the end of the line
    (end-of-line)
    (setq include-insertion-point (point))
    include-insertion-point
    
    )				; end of the let body
  )					; end of defun