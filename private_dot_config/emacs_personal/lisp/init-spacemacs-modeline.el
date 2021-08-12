;;; init-spacemacs-modeline.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; Modeline Bar
(straight-use-package 'all-the-icons)
(straight-use-package 'spaceline-all-the-icons)
(straight-use-package 'spaceline)
(straight-use-package 'info)
(straight-use-package 'all-the-icons)
(spaceline-helm-mode)
(spaceline-info-mode)
(require 'spaceline-config)
(spaceline-spacemacs-theme)

(setq powerline-height 25)
(setq powerline-default-separator 'rounded)
(setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state) ;; Show Evil State

(spaceline-compile)

(provide 'init-spacemacs-modeline)
;;; init-spacemacs-modeline.el ends here
