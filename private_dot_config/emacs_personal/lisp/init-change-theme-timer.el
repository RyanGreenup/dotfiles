
;;; init-change-theme-timer.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(defun set-theme-for-time-of-day
    ()
  ;; more readable :)
  (when
      (display-graphic-p)
    ;; Should not run in the terminal
    "Set the theme depending on the time of day, ideal for startup."  
    ;; TODO Make this only change the theme if it needs to be and then have it run every 30 minutes
    (defvar init-current-time
      (string-to-number
       (format-time-string "%H")))
    (defvar is-daytime
      (and
       (>  init-current-time 5)
       (< init-current-time 17))
      )
    (defvar is-evening
      (and
       (<  init-current-time 5)
       (> init-current-time 17))
      )
    (if is-daytime
	(load-theme 'light-blue)
      (load-theme 'flucui-dark)
      )
    )
  )
(provide 'init-change-theme-timer)
;;; init-change-theme-timer.el ends here
