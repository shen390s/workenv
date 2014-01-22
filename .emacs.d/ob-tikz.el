;;; ob-tikz.el --- org-babel functions for tikz evaluation

;; Copyright (C) 2009-2012  Free Software Foundation, Inc.

;; Author: Rongsong Shen
;; Keywords: literate programming, tikz
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

;; Org-Babel support for evaluating tikz source code.
;;
;; This differs from most standard languages in that
;;
;; 1) there is no such thing as a "session" in tikz
;;
;; 2) we are generally only going to return results of type "file"
;;
;; 3) we are adding the "file" and "cmdline" header arguments, if file
;;    is omitted then the -V option is passed to the tikz command for
;;    interactive viewing

;;; Requirements:

;;
;; - tikz-mode :: Major mode for editing tikz files

;;; Code:
(require 'ob)
(eval-when-compile (require 'cl))
(require 'latex)

(add-to-list 'org-babel-tangle-lang-exts '("tikz" . "tikz"))

(define-derived-mode tikz-mode
  latex-mode "tikz/pgf"
  "Major mode for tikz/pgf script"
  )

(font-lock-add-keywords 
 'tikz-mode
 '(("\\draw" . font-lock-keyword-face)
   ("\\filldraw" . font-lock-keyword-face)
   ("\\clip" . font-lock-keyword-face)
   ("\\shadowdraw" . font-lock-keyword-face)
   ("\\path" . font-lock-keyword-face)
   ("\\foreach" . font-lock-keyword-face)
   ("\\node" . font-lock-keyword-face)
   ("\\fill" . font-lock-keyword-face)
   ))

(defvar org-babel-default-header-args:tikz
  '((:results . "file") (:exports . "results"))
  "Default arguments when evaluating an Tikz source block.")

(defcustom org-tikz-program "pdflatex"
  "Command of tikz. The command should use command line `pdflatex sourcefile'"
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defcustom org-tikz-convert "convert"
  "Command for convert picture format. The command should use format `convert source destintion'"
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defvar tikz-prologues)
(defvar tikz-script)
(defvar tikz-m-end)
(defvar tikz-m-start)
(defvar tikz-var-type)
(defvar tikz-var-value)
(defvar tikz-vpair)

(defun tikz-script (fmt tikz-libs body)
  (setq tikz-prologues 
	(concat "\\documentclass{article}\n"
		"\\usepackage{tikz}\n"
		"\\usetikzlibrary{external}\n"
		(if tikz-libs
		    (concat "\\usetikzlibrary{"
			    tikz-libs
			    "}\n")
		  "")
		"\\tikzexternalize\n"
		"\\begin{document}\n"
		"\\begin{tikzpicture}"))

  (setq tikz-script-data (concat body
				 "\n\\end{tikzpicture}\n"
				 "\\end{document}\n"))
  (message "%s" (concat tikz-prologues tikz-script-data))
  (concat tikz-prologues tikz-script-data)
)

(defun tikz-post-run (fmt in-file out-file)
  (shell-command (concat org-tikz-convert " "
			 (concat org-babel-temporary-directory "/"
				 (file-name-nondirectory in-file) 
				 "-figure0.pdf")
			 " "
			 out-file))
)
 
(defun org-babel-execute:tikz (body params)
  "Execute a block of Tikz code.
This function is called by `org-babel-execute-src-block'."
  (let* ((result-params (split-string (or (cdr (assoc :results params)) "")))
         (out-file (cdr (assoc :file params)))
         (format (or (and out-file
                          (string-match ".+\\.\\(.+\\)" out-file)
                          (match-string 1 out-file))
                     "pdf"))
         (cmdline (cdr (assoc :cmdline params)))
         (in-file (org-babel-temp-file "tikz-"))
         (cmd
	  (concat (concat org-tikz-program " -shell-escape ")
		  (org-babel-process-file-name in-file)
		  )))
    (with-temp-file (concat in-file ".tex") 
      (insert (tikz-script format 
			   (tikz-get-value-by-name 'tikz-libs
						   (mapcar #'cdr (org-babel-get-header params :var)))
			   (org-babel-expand-body:generic
			    body params 
			    (org-babel-variable-assignments:tikz params)))))
    (message cmd) (shell-command (concat "cd " org-babel-temporary-directory ";"
					 cmd))
    (tikz-post-run format in-file out-file)
    nil)) ;; signal that output has already been written to file

(defun org-babel-prep-session:tikz (session params)
  "Return an error if the :session header argument is set.
Tikz does not support sessions"
  (error "Tikz does not support sessions"))

(defun org-babel-variable-assignments:tikz (params)
  "Return list of tikz statements assigning the block's variables"
  (mapcar #'org-babel-tikz-var-to-tikz
	  (mapcar #'cdr (org-babel-get-header params :var)))
)

(defun tikz-get-value-by-name (name vpairs)
  (let ((vp (assoc name vpairs)))
    (if vp
	(cdr vp)
      nil))
)

(defun org-babel-tikz-var-value (val)
  val
  )

(defun org-babel-tikz-var-to-tikz (pair)
  "Convert an elisp value into an Tikz variable.
The elisp value PAIR is converted into Tikz code specifying
a variable of the same value."
  nil
  )

(defun org-babel-tikz-define-type (data)
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

(provide 'ob-tikz)
;;; ob-tikz.el ends here
