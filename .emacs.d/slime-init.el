(setq inferior-lisp-program "sbcl")

(defvar *quicklisp-url* 
  "http://beta.quicklisp.org/quicklisp.lisp")
(defvar *quicklisp-dir* "~/quicklisp")
(defvar *quicklisp-file* "quicklisp.lisp")

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

(defvar *slime-install-commands*
  '("quicklisp-quickstart:install"
    "ql:update-client"
    "ql:quickload \"quicklisp-slime-helper\""
    "ql:add-to-init-file"))

(defun quicklisp-run-install-script (proc)
  (process-send-string proc 
		       (concat "(load #p\"" 
			       (expand-file-name (concat *quicklisp-dir* "/"
							 *quicklisp-file*))
			       "\")\n"))
  (dolist (cmd *slime-install-commands*)
    (process-send-string proc (concat "(" cmd ")\n\n"))))

(defun start-lisp()
  (let ((buf (get-buffer-create "*lisp*")))
    (progn (set-buffer buf)
	   (start-process "lisp"
			  buf
			  inferior-lisp-program))))

(defun load-slime ()
  (progn (load (expand-file-name (concat *quicklisp-dir* 
					 "/slime-helper.el")))
	 (my-slime-add-contribs 'slime-mrepl
				'slime-banner
				'slime-xref-browser)))

(defun after-install (process event)
  (load-slime))

(defun quicklisp-install ()
  (let ((sbcl (start-lisp))) 
    (set-process-sentinel sbcl 'after-install)
    (quicklisp-run-install-script sbcl)
    (process-send-string sbcl "(quit)\n\n")))

(if (file-exists-p (concat *quicklisp-dir* 
			   "/slime-helper.el"))
    (load-slime)
  (progn (unless (file-exists-p *quicklisp-dir*)
	   (mkdir *quicklisp-dir*))
	 (let ((quicklisp (concat *quicklisp-dir* "/"
				  *quicklisp-file*)))
	 (unless (file-exists-p quicklisp)
	   (url-copy-file *quicklisp-url* quicklisp))
	 (quicklisp-install))))

