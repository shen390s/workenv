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
 `(org-plantuml-jar-path ,(concat *misc-dir* "/plantuml.jar")))

