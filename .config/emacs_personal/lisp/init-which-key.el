;;; init-which-key.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;; This should be edited in close connection with 
;; ./init-evil.el

;; Setting up menus is non-trivial
;; See the instructions https://github.com/justbur/emacs-which-key#paging-options
;; I may as well just visit the keybindings/evil .el files tbh, KISS.
;;; Code:

;;;; Set Idle Delays (BEFORE which-key-Mode)
(setq which-key-idle-delay 0.1) ;; Must be > 0
(setq eldoc-idle-delay 0)  ;; these should be close ish, this can be 0
;;;;; Enable Which Key Mode
(which-key-mode 1)
;;;;; Change Symbols
(add-to-list 'which-key-replacement-alist '(("TAB" . nil) . ("↹" . nil)))
(add-to-list 'which-key-replacement-alist '(("RET" . nil) . ("⏎" . nil)))
(add-to-list 'which-key-replacement-alist '(("DEL" . nil) . ("⇤" . nil)))
(add-to-list 'which-key-replacement-alist '(("SPC" . nil) . ("␣" . nil)))


(provide 'init-which-key)
;;; init-which-key.el ends here
