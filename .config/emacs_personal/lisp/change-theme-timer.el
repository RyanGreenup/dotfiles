;;; temp.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;; <Color theme initialization code>
(setq current-theme '(color-theme-solarized-light))

(defun synchronize-theme ()
    (setq hour 
        (string-to-number 
            (substring (current-time-string) 11 13)))
    (if (member hour (number-sequence 6 17))
        (setq now '(color-theme-solarized-light))
        (setq now '(color-theme-solarized-dark))) 
    (if (equal now current-theme)
        nil
        (setq current-theme now)
        (eval now) ) ) ;; end of (defun ...

(run-with-timer 0 3600 synchronize-theme)

(provide 'temp)
;;; temp.el ends here
