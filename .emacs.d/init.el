;;; Add initialization here
(defvar *custom-dir* "/home/rshen/.emacs.d")
(add-to-list 'load-path *custom-dir*)

;; define the package which are needed
;; to be loaded
(defvar *load-init* '("org.el"))
(defvar *misc-dir* (concat *custom-dir* "/misc"))

;; load initialize packages
(dolist (pkg *load-init*)
  (load-file pkg))
