(eval-when-compile
  (require 'cl-lib)
  (require 'vc)
  (require 'vc-dir)
  (require 'grep))

(defgroup vc-rtc nil
  "VC IBM RTC backend"
  :version "24.1"
  :group 'vc)

(defcustom vc-rtc-program "lscm"
  "Name of the RTC executable(excluding any arguments)."
  :version "24.1"
  :type 'string
  :group 'vc-rtc)

(defvar vc-rtc-json-format nil)

(defun vc-rtc-revision-granularity ()
  'repository)

(defun vc-rtc-checkout-model (_files)
  'implicit)

(defun vc-rtc-root (file)
  (message "trying to find rtc root...\n")
  (or (vc-file-getprop file 'rtc-root)
      (vc-file-setprop file 'rtc-root
		       (vc-find-root file ".jazz5")))
  (unless vc-rtc-json-format
    (and (vc-rtc-command nil 0 nil "preference" 
			 "set" "json.output"
			 "true")
	 (setq vc-rtc-json-format t))))

(defun rtc-workspace (json)
  (aref (cdr (assoc 'workspaces (car json))) 0))

(defun rtc-userId (workspace)
  (cdr (assoc 'userId workspace)))

(defun rtc-url (workspace)
  (cdr (assoc 'url workspace)))

(defun rtc-workspace-name (workspace)
  (cdr (assoc 'name workspace)))

(defun rtc-components (workspace)
  (cdr (assoc 'components workspace)))

(defun rtc-component-unresolved (component)
  (cdr (assoc 'unresolved component)))

(defun rtc-component-suspended (component)
  (cdr (assoc 'suspended component)))

(defun rtc-component-name (component)
  (cdr (assoc 'name component)))

(defun rtc-component-incoming-changes (component)
  (cdr (assoc 'incoming-changes component)))

(defun rtc-component-outgoing-changes (component)
  (cdr (assoc 'outgoing-changes component)))

(defun rtc-changeset-workitems (changeset)
  (cdr (assoc 'workitems changeset)))

(defun rtc-workitem-id (workitem)
  (cdr (assoc 'id workitem)))

(defun rtc-workitem-label (workitem)
  (cdr (assoc 'workitem-label workitem)))

(defun rtc-unresolved-state (item)
  (let ((state (cdr (assoc 'state item))))
    (loop for (prop . ison?) in state
	  when (eq ison? 't) collect prop)))

(defun rtc-unsolved-file (item)
  (cdr (assoc 'path item)))

(defun vc-rtc-command (buffer okstatus file-or-list &rest flags)
  "A wrapper around `vc-do-command' for use in vc-rtc.el.
The difference to vc-do-command is that this function always invokes
`vc-rtc-program'."
  (apply 'vc-do-command (or buffer "*vc*")
	 okstatus vc-rtc-program 
	 file-or-list (cons () flags)))

(defun vc-rtc-dir-status (_dir update-function)
  (message "get directory status...\n")
  (vc-rtc-command (current-buffer) 'async 
		  nil "status" "-v")
  (let ((s (buffer-string (current-buffer))))
    (let ((json (json-read-from-string s)))
      t)))

(defun vc-rtc-create-repo ()
  t
)

(defun vc-rtc-register (files &optional _rev _comment)
  t
)

(defun vc-rtc-dir-extra-headers (_dir)
  )

(defalias 'vc-rtc-responsible-p 'vc-rtc-root)

(provide 'vc-rtc)
