;;; -*- lexical-bindings: t -*-

(require 'cl-lib)
(require 'package)


(defun read-sexp-from-file (filename)
  (save-window-excursion
    (find-file-literally filename)
    (let ((str (buffer-string)))
      (car (read-from-string str)))))

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-refresh-contents)
(package-initialize)


(cl-loop for (name . ignore) in (read-sexp-from-file "~/.emacs.d/backup/packages.el")
         do (progn
              (princ (format "%s\n" name))
              (package-install name)))

