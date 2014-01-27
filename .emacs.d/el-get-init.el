(add-to-list 'load-path 
	     (concat *custom-dir* 
		     "/el-get/el-get"))

(defvar *el-get-url*
  "https://raw.github.com/dimitri/el-get/master/el-get-install.el")

(defvar el-get-git-install-url
  "https://github.com/shen390s/el-get.git")
  
(setq el-get-user-package-directory
      (concat *custom-dir*
	      "/el-get-init-files"))

(setq el-get-verbose t)

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously *el-get-url*)
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

(setq el-get-sources
      '((:name el-get :branch "master")))

(setq my-packages
      (append 
       '(auctex org-mode main-line) 
       (mapcar 'el-get-as-symbol
	       (mapcar 'el-get-source-name el-get-sources))))

(el-get 'sync my-packages)
