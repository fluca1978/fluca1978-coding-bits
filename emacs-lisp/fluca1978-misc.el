;; Miscellaneous functions and hacks
;;
;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffer list management

;; A function to display the buffer list and give the focus to such
;; buffer list.
(defun list-buffers-with-focus () 
  "Opens the list buffers buffer and sets the focus to such buffer"
  (interactive)

  ;; open the list buffers windows ("*Buffer List*)
  (list-buffers)
  ;; advance to the next window, that is always the buffer window
  (other-window 1)
)

;; attach the new list-buffers-with-focus function to the
;; list buffer shortcut (C-x C-b)
;(global-set-key (kbd "C-x C-b") 'list-buffers-with-focus)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;