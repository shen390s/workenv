(setq inferior-lisp-program "sbcl")

(defun my-slime-add-contribs (&rest contribs)
  (when contribs
    (let ((p (expand-file-name "contrib" slime-path)))
      (when (not (member p load-path))
        (add-to-list 'load-path p)))
    (require 'slime)
    (dolist (c contribs)
      (require c)
      (let ((init (intern (format "%s-init" c))))
        (when (fboundp init)
          (funcall init))
        (when (not (member c slime-setup-contribs))
          (add-to-list 'slime-setup-contribs c))
        )))) 

(if (file-exists-p "~/quicklisp/asdf.lisp")
    (progn (load (expand-file-name "~/quicklisp/slime-helper.el"))
	   (my-slime-add-contribs 'slime-mrepl
				  'slime-banner
				  'slime-xref-browser))
  (message "Please run command `sbcl --load ~/quicklisp/slime-setup.lisp"))


