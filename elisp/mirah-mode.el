;;; mirah-mode.el --- A major mode for Mirah programing language  -*- lexical-binding: t; -*-

;; Copyright (C) 2014  金舜琳

;; Author: 金舜琳(Sunrim KIM) or κeen <3han5chou7@gmail.com>
;; Keywords: languages

;;; Commentary:

;; This is a major mode for Mirah lang.

;;; Installation:
;; add code below to your init.el
; (autoload #'mirah-mode "mirah-mode" "major-mode for mirah" t)
; (add-to-list 'load-path "/path/to/mirah-mode.el")
; (add-to-list 'auto-mode-alist '("\\.mirah$" . mirah-mode))
;;; Code:

(require 'ruby-mode)
(defvar mirah-keywords
  '("import" "as" "macro" "interface" "package" "implements" "enum"))

(defvar mirah-builtins '("quote" "synchronized" "abstract" "volatile"))
(defvar mirah-builtins-re-sexp "")
(defvar mirah-type-re-sexp
  '(and symbol-start (submatch (or  "boolean" "byte" "char" "short" "int" "long" "float" "double")) (char ?\( ?\[)))


(defun mirah-syntax-propertize-function (start end)
  "Syntactic keywords for Ruby mode.  See `syntax-propertize-function'."
  (let (case-fold-search)
    (goto-char start)
    (remove-text-properties start end '(ruby-expansion-match-data))
    (ruby-syntax-propertize-heredoc end)
    (ruby-syntax-enclosing-percent-literal end)
    (funcall
     (syntax-propertize-rules
      ;; $' $" $` .... are variables.
      ;; ?' ?" ?` are character literals (one-char strings in 1.9+).
      ("\\([?$]\\)[#\"'`]"
       (1 (if (save-excursion
                (nth 3 (syntax-ppss (match-beginning 0))))
              ;; Within a string, skip.
              (goto-char (match-end 1))
            (string-to-syntax "\\"))))
      ;; Part of symbol when at the end of a method name.
      ("[!?]"
       (0 (unless (save-excursion
                    (or (nth 8 (syntax-ppss (match-beginning 0)))
                        (eq (char-before) ?:)
                        (let (parse-sexp-lookup-properties)
                          (zerop (skip-syntax-backward "w_")))
                        (memq (preceding-char) '(?@ ?$))))
            (string-to-syntax "_"))))
      ("\n"
       (0
        (let* ((state (save-excursion (syntax-ppss (match-beginning 1))))
               (in-comment (nth 4 state))
               (start (nth 8 state)))
          (if (and in-comment (char-equal (char-after start) ?#))
           (string-to-syntax ">")))
        ))
      ("\\(/\\)\\*"
       (1
        (unless (nth 4 (save-excursion (syntax-ppss (match-beginning 1))))
          (string-to-syntax "<"))))
      ("\\*\\(/\\)"
       (1
        (let* ((state (save-excursion (syntax-ppss (match-beginning 1))))
               (in-comment (nth 4 state))
               (start (nth 8 state))
               (end (match-end 1)))
          (if (and in-comment (string-match "/\\*" (buffer-substring start (min (+ start 2) (point-max))))
                   (= (count-matches "/\\*" start end) (count-matches "\\*/" start end)))
           (string-to-syntax ">")))
        ))
      ;; Regular expressions.  Start with matching unescaped slash.
      ("\\(?:\\=\\|[^\\]\\)\\(?:\\\\\\\\\\)*\\(/\\)"
       (1 (let ((state (save-excursion (syntax-ppss (match-beginning 1)))))
            (when (or
                   ;; Beginning of a regexp.
                   (and (null (nth 8 state))
                        (save-excursion
                          (forward-char -1)
                          (looking-back ruby-syntax-before-regexp-re
                                        (point-at-bol))))
                   ;; End of regexp.  We don't match the whole
                   ;; regexp at once because it can have
                   ;; string interpolation inside, or span
                   ;; several lines.
                   (eq ?/ (nth 3 state)))
              (string-to-syntax "\"/")))))
      ;; Expression expansions in strings.  We're handling them
      ;; here, so that the regexp rule never matches inside them.
      (ruby-expression-expansion-re
       (0 (ignore (ruby-syntax-propertize-expansion))))
      ("^=en\\(d\\)\\_>" (1 "!"))
      ("^\\(=\\)begin\\_>" (1 "!"))
      ;; Handle here documents.
      ((concat ruby-here-doc-beg-re ".*\\(\n\\)")
       (7 (unless (or (nth 8 (save-excursion
                               (syntax-ppss (match-beginning 0))))
                      (ruby-singleton-class-p (match-beginning 0)))
            (put-text-property (match-beginning 7) (match-end 7)
                               'syntax-table (string-to-syntax "\""))
            (ruby-syntax-propertize-heredoc end))))
      ;; Handle percent literals: %w(), %q{}, etc.
      ((concat "\\(?:^\\|[[ \t\n<+(,=]\\)" ruby-percent-literal-beg-re)
       (1 (prog1 "|" (ruby-syntax-propertize-percent-literal end)))))
     (point) end)))

;;;###autoload
(define-derived-mode mirah-mode ruby-mode "Mirah" "major-mode for mirah"
  (font-lock-add-keywords nil
                          `((,(rx (eval mirah-type-re-sexp))
                             1
                             'font-lock-type-face)
                            (,(rx symbol-start (submatch (eval (cons 'or mirah-keywords))) symbol-end)
                             1
                             'font-lock-keyword-face)
                            (,(rx (or (submatch (eval (cons 'or mirah-builtins)))))
                             1
                             'font-lock-builtin-face)))
  (setq-local font-lock-syntax-table
              (let ((table (make-syntax-table ruby-font-lock-syntax-table)))
                (modify-syntax-entry ?\n "." table)
                table))
  (setq-local syntax-propertize-function #'mirah-syntax-propertize-function))
;; ;;;###autoload
;; (add-to-list 'interpreter-mode-alist (cons "mirah" 'mirah-mode))

;; ;;;###autoload
;; (add-hook mirah-mode-hook
;;           (lambda ()
;;             (set (make-local-variable 'compile-command)
;;                  (concat
;;                   (if (executable-find "mirahc")
;;                       "mirahc"
;;                     "java -jar mirahc.jar")
;;                   (if buffer-file-name
;;                              (shell-quote-argument
;;                               (file-name-sans-extension buffer-file-name)))))))

(provide 'mirah-mode)
;;; mirah-mode.el ends here

