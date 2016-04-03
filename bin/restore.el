;;; -*- lexical-bindings: t -*-

(require 'cl-lib)


(defun read-sexp-from-file (filename)
  (save-window-excursion
    (find-file-literally filename)
    (let ((str (buffer-string)))
      (car (read-from-string str)))))

(cl-loop for (name . ignore) in (read-sexp-from-file "~/.emacs.d/backup/packages.el")
         do (package-install name))

