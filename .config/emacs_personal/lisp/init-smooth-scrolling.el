;;; init-smooth-scrolling.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun adjust-scrolling-rate ()
    (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
    (setq mouse-wheel-progressive-speed t)		;;  accelerate scrolling
    (setq mouse-wheel-follow-mouse 't)			;; scroll window under mouse
    (setq scroll-step 1)				;; keyboard scroll one line at a time
    (smooth-scrolling-mode 1)                           ;; Keenp Point centered when scrolling with up/down
    )
(adjust-scrolling-rate)


(provide 'init-smooth-scrolling)
;;; init-smooth-scrolling.el ends here
