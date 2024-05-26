;; Install Packages
;; Install a package via the elpaca macro
;; See the "recipes" section of the manual for more details.

;; Install use-package support
(elpaca elpaca-use-package
;; Enable use-package :ensure support for Elpaca.
(elpaca-use-package-mode))

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use the :wait recipe keyword to block until that package has been installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)

(defun config-evil()
  (evil-mode 1)
    (define-key evil-normal-state-map (kbd "TAB") 'evil-toggle-fold))
(use-package evil :ensure t :demand t :config (config-evil) )

(use-package ivy :ensure t :demand t :config (ivy-mode 1))

;; (defun config-nano()
;;     (interactive)
;;     (setq my-font "RobotoMono Nerd Font")
;;     (add-to-list 'default-frame-alist '(font . my-font))
;;     (set-face-attribute 'default t :font my-font)
;;     (setq nano-font-family-monospaced my-font)
;;     (setq nano-font-family-proportional nil))
;; (use-package nano :ensure (:host github :repo "rougier/nano-emacs") :config (config-nano))
;; (use-package elegant :ensure (:host github :repo "rougier/elegant-emacs"))

;; (use-package helm
;;              :ensure t
;;              :demand t
;;              :config (global-set-key (kbd "M-x") 'helm-M-x))

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))

; (load "/home/ryan/.config/emacs_org_only/org-locations.el")
; (require 'org-locations)


