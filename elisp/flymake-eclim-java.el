(defvar flymake-eclipse-batch-compiler-path
  "/opt/homebrew-cask/Caskroom/eclipse-platform/4.4.2-201502041700/eclipse/plugins/org.eclipse.jdt.core_3.10.2.v20150120-1634.jar")

;; TODO fix hardcoded 1.6
(defvar flymake-java-version "1.8")

(defun flymake-java-ecj-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-ecj-create-temp-file))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "java" (list "-jar" flymake-eclipse-batch-compiler-path "-Xemacs" "-d" "none"
                       "-warn:+over-ann,uselessTypeCheck";;,allJavadoc"
                       "-source" flymake-java-version "-target" flymake-java-version "-proceedOnError"
                       "-classpath" (eclim/project-classpath)
                       ;; "-log" "c:/temp/foo.xml"
                       local-file))))

(defun flymake-java-ecj-cleanup ()
  "Cleanup after `flymake-java-ecj-init' -- delete temp file and dirs."
  (flymake-safe-delete-file flymake-temp-source-file-name)
  (when flymake-temp-source-file-name
    (flymake-safe-delete-directory (file-name-directory flymake-temp-source-file-name))))
(defun flymake-ecj-create-temp-file (file-name prefix)
  "Create the file FILE-NAME in a unique directory in the temp directory."
  (file-truename (expand-file-name (file-name-nondirectory file-name)
                                   (expand-file-name (int-to-string (abs (random))) (flymake-get-temp-dir)))))
(push '(".+\\.java$" flymake-java-ecj-init flymake-java-ecj-cleanup) flymake-allowed-file-name-masks)

(provide 'flymake-eclim-java)
