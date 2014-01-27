;; (defvar slime-path 
;;   (concat *custom-dir* "/el-get/slime"))

;; (add-to-list 'load-path slime-path)
;; (require 'slime-tests)

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

(load (expand-file-name "~/quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

(my-slime-add-contribs 'slime-mrepl
                       'slime-banner
                       'slime-xref-browser)

