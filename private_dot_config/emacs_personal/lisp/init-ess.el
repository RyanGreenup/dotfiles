;;; init-ess.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; ESS Settings
;;;; Auto-Scroll Inferior Buffer
;; (setq comint-prompt-read-only t) ;; Avoid this, causes problems [[https://stackoverflow.com/a/2710510/10593632]]
(setq comint-scroll-to-bottom-on-input t) ;; does
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
;;;; Insert R Heading





(defun Insert-R-Heading-1 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## * ")
          (insert hname)

          (insert " ")
          (insert
            (apply 'concat (make-list (- 73 hlen) "-"))
           )
       )
     )
    )
)
(defun Insert-R-Heading-2 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## ** ")
          (insert hname)
          (insert " ")
          (insert
            (apply 'concat (make-list (- 72 hlen) "="))
           )
       )
     )
    )
)
(defun Insert-R-Heading-3 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## *** ")
          (insert hname)
          (insert " ")
          (insert
            (apply 'concat (make-list (- 71 hlen) "#"))
           )
       )
     )
    )
)



(provide 'init-ess)
;;; init-ess.el ends here
