;; Set Global Variables

(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Load Sub Packages

(defun load-relative(path)
  (load (expand-file-name path user-emacs-directory)))

(load-relative "elpaca_init.el")
(load-relative "theme.el")
(load-relative "packages.el")
(load-relative "org-agenda/locations.el")
(load-relative "keybindings/org.el")




(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   '("/home/ryan/Agenda/todo.org" "/home/ryan/Agenda/habits.org" "/home/ryan/Agenda/projects.org")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; (define-key evil-normal-state-map (kbd "<tab>") 'evil-toggle-fold)
