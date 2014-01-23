;;; Add initialization here
(defvar *custom-dir* "/home/rshen/.emacs.d")

(add-to-list 'load-path *custom-dir*)
(setq custom-file (concat *custom-dir* "/custom.el"))

(if (file-exists-p custom-file)
    (load custom-file))

;; define the package which are needed
;; to be loaded
(defvar *load-init* '("org-init.el" 
		      "slime-init.el" 
		      "my-c-init.el" 
		      "vc-init.el"))
(defvar *misc-dir* (concat *custom-dir* "/misc"))

;; load initialize packages
(dolist (pkg *load-init*)
  (load-file (concat *custom-dir* "/" pkg)))

