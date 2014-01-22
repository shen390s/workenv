;;; ob-metapost.el --- org-babel functions for metapost evaluation

;; Copyright (C) 2009-2012  Free Software Foundation, Inc.

;; Author: Rongsong Shen
;; Keywords: literate programming, metapost
;; Homepage: http://orgmode.org

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating metapost source code.
;;
;; This differs from most standard languages in that
;;
;; 1) there is no such thing as a "session" in metapost
;;
;; 2) we are generally only going to return results of type "file"
;;
;; 3) we are adding the "file" and "cmdline" header arguments, if file
;;    is omitted then the -V option is passed to the metapost command for
;;    interactive viewing

;;; Requirements:

;;
;; - metapost-mode :: Major mode for editing metapost files

;;; Code:
(require 'ob)
(eval-when-compile (require 'cl))

(add-to-list 'org-babel-tangle-lang-exts '("metapost" . "mp"))

(defvar org-babel-default-header-args:metapost
  '((:results . "file") (:exports . "results"))
  "Default arguments when evaluating an Metapost source block.")

(defcustom org-metapost-program "mpost"
  "Command of metapost. The command should use command line `mpost sourcefile'"
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defcustom org-metapost-convert "convert"
  "Command for convert picture format. The command should use format `convert source destintion'"
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defvar mp-prologues)
(defvar mp-script)
(defvar mp-m-end)
(defvar mp-m-start)
(defvar mp-var-type)
(defvar mp-var-value)
(defvar mp-vpair)

(defun metapost-script (fmt body)
  (setq mp-prologues 
	(cond ((string= fmt "svg") "outputformat:=\"svg\";\n")
	      (t "prologues:=3;\n")))

  (setq mp-script (concat "beginfig(1);\n"
			  body
			  "\nendfig;\n"
			  "end\n"))
  (message "%s" mp-script)
  (concat mp-prologues mp-script)
)

(defun metapost-post-run (fmt in-file out-file)
  (cond ((or (string= fmt "svg")
	     (string= fmt "eps"))
	 (copy-file (concat (file-name-nondirectory in-file) ".1") out-file))
	(t (shell-command (concat (concat org-metapost-convert " ")
				  (concat (file-name-nondirectory in-file) 
					  ".1")
				  " "
				  out-file)))
	)
)
 
(defun org-babel-execute:metapost (body params)
  "Execute a block of Metapost code.
This function is called by `org-babel-execute-src-block'."
  (let* ((result-params (split-string (or (cdr (assoc :results params)) "")))
         (out-file (cdr (assoc :file params)))
         (format (or (and out-file
                          (string-match ".+\\.\\(.+\\)" out-file)
                          (match-string 1 out-file))
                     "pdf"))
         (cmdline (cdr (assoc :cmdline params)))
         (in-file (org-babel-temp-file "metapost-"))
         (cmd
	  (concat (concat org-metapost-program " ")
		  (org-babel-process-file-name in-file))))
    (with-temp-file in-file
      (insert (metapost-script format
	       (org-babel-expand-body:generic
		body params 
		(org-babel-variable-assignments:metapost params)))))
    (message cmd) (shell-command cmd)
    (metapost-post-run format in-file out-file)
    nil)) ;; signal that output has already been written to file

(defun org-babel-prep-session:metapost (session params)
  "Return an error if the :session header argument is set.
Metapost does not support sessions"
  (error "Metapost does not support sessions"))

(defun org-babel-variable-assignments:metapost (params)
  "Return list of metapost statements assigning the block's variables"
  (mapcar #'org-babel-metapost-var-to-metapost
	  (mapcar #'cdr (org-babel-get-header params :var))))

(defconst metapost-type-prefix "^[^:]*:")


(defun org-babel-metapost-var-value (val)
  (setq mp-m-end 0)
  (setq mp-m-start (string-match metapost-type-prefix val))
  (if mp-m-start (setq mp-m-end (match-end 0))
    )
  (setq mp-var-type "")
  (setq mp-var-value val)
  (if (> mp-m-end 0)
      (progn (setq mp-var-type 
		   (substring val mp-m-start (- mp-m-end 1)))
	     (setq mp-var-value
		   (substring val mp-m-end (length val)))
	     )
    )
  (cons mp-var-type (cons mp-var-value nil))
  )

(defun org-babel-metapost-var-to-metapost (pair)
  "Convert an elisp value into an Metapost variable.
The elisp value PAIR is converted into Metapost code specifying
a variable of the same value."
  (let ((var (car pair))
        (val (let ((v (cdr pair)))
  	       (if (symbolp v) (symbol-name v) v))))
    (progn
      (setq mp-vpair (org-babel-metapost-var-value val))
      (setq mp-var-type (nth 0 mp-vpair))
      (setq mp-var-value  (nth 1 mp-vpair))
      (if (string= mp-var-type "string")
	  (format "%s %s;\n %s :=\"%s\";\n"
		  mp-var-type var var mp-var-value
		  )
	(format "%s %s;\n %s := %s;\n"
		mp-var-type var var mp-var-value
		)
	)
      )
    )
  )

(defun org-babel-metapost-define-type (data)
  "Determine type of DATA.

DATA is a list.  Return type as a symbol.

The type is `string' if any element in DATA is
a string. Otherwise, it is either `numeric', if some elements are
floats, or `numeric'."
  (let* ((type 'numeric)
	 find-type			; for byte-compiler
	 (find-type
	  (function
	   (lambda (row)
	     (catch 'exit
	       (mapc (lambda (el)
		       (cond ((listp el) (funcall find-type el))
			     ((stringp el) (throw 'exit (setq type 'string)))
			     ((floatp el) (setq type 'numeric))))
		     row))))))
    (funcall find-type data) type))

(provide 'ob-metapost)
;;; ob-metapost.el ends here
