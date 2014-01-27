;;; Add initialization here
(defvar *custom-dir* "/home/rshen/.emacs.d")

(add-to-list 'load-path *custom-dir*)

(setq custom-file (concat *custom-dir* "/custom.el"))
(if (file-exists-p custom-file)
    (load custom-file))

;; define the package which are needed
;; to be loaded
(defvar *load-init* '("el-get-init" "my-c-init"
		      "vc-init" "slime-init"
		      "org-init"))

(defvar *misc-dir* (concat *custom-dir* "/misc"))

;; load initialize packages
(dolist (pkg *load-init*)
  (load-file (concat *custom-dir* "/" pkg ".el")))


