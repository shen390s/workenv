;;;
(defvar *org-root* "~/.emacs.d/org/")
(dolist (dir '("lisp" "contrib/lisp"))
  (add-to-list 'load-path (concat *org-root* dir)))

(custom-set-variables
 '(org-babel-load-languages 
   (quote ((emacs-lisp . t) 
	   (C . t) 
	   (calc . t) 
	   (ditaa . t) 
	   (gnuplot . t) 
	   (mscgen . t) 
	   (octave . t) 
	   (plantuml . t) 
	   (sh . t) 
	   (haskell . t) 
	   (metapost . t) 
	   (dot . t) 
	   (eukleides . t) 
	   (R . t) 
	   (latex . t) 
	   (tikz . t))))
 '(org-babel-tangle-lang-exts 
   (quote (("emacs-lisp" . "el") 
	   ("metapost" . "mp") 
	   ("Language name" . "File Extension"))))

 '(org-confirm-babel-evaluate nil)
 '(org-eukleides-path "/usr/bin/eukleides")
 `(org-ditaa-jar-path ,(concat *org-root* "contrib/scripts/ditaa.jar"))
 '(org-enforce-todo-dependencies t)
 '(org-export-backends (quote (ascii html icalendar latex odt)))
 '(org-latex-default-packages-alist 
   (quote (("T1" "fontenc" t) 
	   ("" "fixltx2e" nil) 
	   ("" "graphicx" t) 
	   ("" "longtable" nil) 
	   ("" "float" nil) 
	   ("" "wrapfig" nil) 
	   ("" "soul" t) 
	   ("" "textcomp" t) 
	   ("" "marvosym" t) 
	   ("" "wasysym" t) 
	   ("" "latexsym" t) 
	   ("" "amssymb" t) 
	   ("" "amstext" nil) 
	   ("" "hyperref" nil) "\\tolerance=1000")))

 `(org-plantuml-jar-path ,(concat *misc-dir* "/plantuml.jar")))

(defun org-use-xelatex ()
  (interactive)
  (progn (setq org-latex-pdf-process
               (quote ("xelatex -interaction nonstopmode -output-directory %o %f"
                       "bibtex %b" "xelatex -interaction nonstopmode -output-directory %o %f"
                       "xelatex -interaction nonstopmode -output-directory %o %f")))
         t))

(defun org-ignore-title-toc ()
  (interactive)
  (progn (setq org-latex-title-command "\\relax")
         (setq org-latex-toc-command "\\relax")))

(defun org-disable-title-and-toc ()
  (interactive)
  (setq org-latex-title-command "\\relax")
  (setq org-latex-toc-command "\\relax"))

(setq org-babel-temporary-directory "/tmp/babel/")

(defun org-odt-publish-to-odt (plist filename pub-dir)
  (message "odt publishing\n")
  (org-publish-org-to 'odt filename
                      (concat "." (or (plist-get plist :odt-extension)
                                      org-html-extension "odt"))
                      plist pub-dir))

(defun org-before-publish ()
  (if (boundp 'org-babel-temporary-directory)
      (unless (file-exists-p org-babel-temporary-directory)
        (progn
          (make-directory org-babel-temporary-directory t)))))

;; Using xelatex to enable
;; CJK support
(add-hook 'org-mode-hook 'org-use-xelatex)
