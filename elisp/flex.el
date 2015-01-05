; -*- Mode: Emacs-Lisp; -*- 

;  Eric Beuscher
;  Tulane University
;  Department of Computer Science
;  flex-mode.el

(require 'derived)
(require 'cc-mode)

;; (defvar flex-definition-beg nil)
;; (defvar flex-definition-end nil )

;; (defun flex-in-definition-p (&optional pos)
;;   (let ((pos (or pos (point))))
;;     (save-excursion
;;       (goto-char (point-min))
;;       (let ((beg (point-min))
;;             (end (re-search-forward "^%%$")))
;;         (<= beg pos end)))))

;; (defun flex-in-user-code-p (&optional pos)
;;   (let ((pos (or pos (point))))
;;     (save-excursion
;;       (goto-char (point-max))
;;       (let ((beg (re-search-backward "^%%$"))
;;             (end (point-max)))
;;         (<= beg pos end)))))

;; (defun flex-in-c-code-p (&optional pos)
;;   (or (flex-in-user-code-p)))


;; (defun flex-in-definition (regexp)
;;   (concat "\\`\\(?:" regexp ".\\|\n\\)+?\n%%\n"))

;; (defun flex-in-rule (regexp)
;;   (concat "\\`\\(?:.\\|\n\\)*?\n%%\n" regexp "\\(?:.\\|\n\\)*?\n%%\n"))

(defvar flex-mode-font-lock-keywords
  `("" 
    ;; 定数や関数に色付けしたい場合は、consセルにface名とともに設定する。
    ("%{\\(.\\|\n\\)*%}"  (1 font-lock-constant-face))
    (,(regexp-opt '("%%" "%x" "%option" "|")) . font-lock-builtin-face)
    (,(concat "^" (regexp-opt '("%option" "%x")) "[ \t]+\\(.+\\)\n")
     (1 font-lock-variable-name-face))
    (,(concat (regexp-opt '("<" "{")) "\\([a-zA-Z][a-zA-Z0-9_-]+\\)" (regexp-opt '(">" "}")))
     (1 font-lock-keyword-face))
    ("^\\([a-zA-Z][a-zA-Z0-9_-]+\\)\t+.*"
     (1 font-lock-variable-name-face))
;    ("^[^\t]+" . font-lock-string-face)
    ("\"\\(\\\\\"\\|[^\"]\\)*?\"" . font-lock-string-face)))

(defvar flex-mode-syntax-table
  (let ((table (make-syntax-table)))
    (c-populate-syntax-table table)
    ;; (modify-syntax-entry ?<  "(<" table)
    ;; (modify-syntax-entry ?>  ")>" table)
    (modify-syntax-entry ?\" "."  table)
    (modify-syntax-entry ?\' "."  table)
    table)
    "Syntax table for `flex-mode'.")
  
(define-derived-mode flex-mode c-mode "Flex"
  "Major mode for editing flex files"
  
  ;; try to set the indentation correctly
 (setq-default c-basic-offset 4)
 (make-variable-buffer-local 'c-basic-offset)

 (c-set-offset 'knr-argdecl-intro 0)
 (make-variable-buffer-local 'c-offsets-alist)
 (setq-local font-lock-defaults '(flex-mode-font-lock-keywords nil nil))
  ;; remove auto and hungry anything
  (c-toggle-auto-hungry-state -1)
  (c-toggle-auto-state -1)
  (c-toggle-hungry-state -1)

  (use-local-map flex-mode-map)

  ;; get rid of that damn electric-brace which is not useful with flex
  (define-key flex-mode-map "{"	'self-insert-command)
  (define-key flex-mode-map "}"	'self-insert-command)

  (define-key flex-mode-map [tab] 'flex-indent-command)

  (setq comment-start "/*"
	comment-end "*/"
	)
  )

;(defalias 'flex-indent-command 'c-indent-command)

(provide 'flex)
