;;; init-singular.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Set the location of singular.el
;; on Arch this can be inspected with
  ;; pacman -Qlq singular | grep singular.el 
(setq load-path (cons "/usr/share/singular/emacs" load-path))


;; Load the singular.el file
(autoload 'singular "singular"
    "Start Singular using default values." t)

;; Load singular.el with other options
(autoload 'singular-other "singular"
    "Ask for arguments and start Singular." t)


(provide 'init-singular)
;;; init-singular.el ends here
