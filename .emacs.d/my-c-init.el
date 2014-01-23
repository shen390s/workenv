;; offset customizations not in my-c-style
;; This will take precedence over any setting of the syntactic symbol
;; made by a style.

(defun my-c-initialization-hook ()
  (progn (define-key c-mode-base-map "\C-m" 'c-context-line-break)))

(add-hook 'c-initialization-hook 'my-c-initialization-hook)

(setq c-offsets-alist '((member-init-intro . ++)))

;; Create my personal style.

(defconst my-c-style
  '((c-tab-always-indent        . t)
					;    (c-comment-only-line-offset . 4)
    (c-hanging-braces-alist     . ((substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . 4)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t))
  "My C Programming Style")

(c-add-style "PERSONAL" my-c-style)

(require 'srecode)

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  (c-set-style "PERSONAL")
  ;; other customizations
  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we like auto-newline, but not hungry-delete
  (c-toggle-auto-newline 1)
  (gtags-mode 1)
  (srecode-minor-mode 1)
  (hs-minor-mode 1))

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(defun add-c-function-header (function-name)
  "Add header description of c/c++ functions"
  (interactive "sFunction Name:")
  (progn
    (insert "/*\n")
    (insert " *---------------------------------------------------------------------------------\n")
    (insert " *\n")
    (insert (concat " *  " function-name "() --\n"))
    (insert " *\n")
    (insert " *   DESCRIPTION:\n")
    (insert " *\n")
    (insert " *   ARGS:\n")
    (insert " *\n")
    (insert " *   RETURN:\n")
    (insert " *\n")
    (insert " *---------------------------------------------------------------------------------\n")
    (insert " */\n")
    ))
