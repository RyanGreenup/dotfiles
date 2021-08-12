;;; init-evil.el --- Load the Evil Layer and Leader  keys   ---
;;; Commentary:
;;; Code:


;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil)
  )

;; Enable Evil
(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode)

;; Leader Keys
(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'insert (kbd "M-SPC"))
(evil-set-leader 'visual (kbd "M-SPC"))
(evil-set-leader 'replace (kbd "M-SPC"))
(evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)
(evil-define-key 'normal 'global (kbd "<leader>wv") 'evil-window-vsplit)
(evil-define-key 'normal 'global (kbd "<leader>ws") 'evil-window-split)
(evil-define-key 'normal 'global (kbd "<leader>wd") 'evil-quit)
(evil-define-key 'normal 'global (kbd "<leader>wl") 'evil-window-right)
(evil-define-key 'normal 'global (kbd "<leader>wh") 'evil-window-left)
(evil-define-key 'normal 'global (kbd "<leader>wj") 'evil-window-down)
(evil-define-key 'normal 'global (kbd "<leader>wk") 'evil-window-up)
(evil-define-key 'normal 'global (kbd "<leader>bp") 'previous-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bn") 'next-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bd") 'kill-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bD") 'kill-buffer-and-window)
(evil-define-key 'normal 'global (kbd "<leader>fy") 'My-Copy-File-Path)
(evil-define-key 'normal 'global (kbd "<leader>ff") 'find-file)
(evil-define-key 'normal 'global (kbd "<leader>ht") 'load-theme)
(evil-define-key 'normal 'global (kbd "<leader>hrt") 'reset-theme)
(evil-define-key 'normal 'global (kbd "<leader>fr") 'consult-recent-file)
(evil-define-key 'normal 'global (kbd "<leader>fp") 'open-local-config)
(evil-define-key 'normal 'global (kbd "<leader>ss") 'swiper)
(evil-define-key 'normal 'global (kbd "<leader>SPC") 'projectile--find-file)
(evil-define-key 'normal 'global (kbd "<leader>gs") 'magit-stage-file)
(evil-define-key 'normal 'global (kbd "<leader>gS") 'magit-stage-modified)
(evil-define-key 'normal 'global (kbd "<leader>gc") 'magit-commit)
(evil-define-key 'normal 'global (kbd "<leader>bb") 'consult-buffer)
(evil-define-key 'normal 'global (kbd "<leader>nrf") 'org-roam-node-find)
(evil-define-key 'normal 'global (kbd "<leader>nri") 'org-roam-node-insert)
(evil-define-key 'normal 'global (kbd "<leader>'") 'ivy-resume)

;; Move up and Down in Agenda
;; In the agenda evil doesn't work, because there are already other
;; keybindings like F for follow mode, map j/k as a compromise

;; (with-eval-after-load 'org
;;   (define-key org-agenda-mode-map "j" 'org-agenda-next-line)
;;   (define-key org-agenda-mode-map "k" 'org-agenda-previous-line)
;;   )

(defun reset-theme ()
  "Unload the theme"
  (interactive)
  (save-window-excursion
    (eval (mapc 'disable-theme custom-enabled-themes) t)
    )
  )


(defun open-local-config ()
  (interactive)
  (find-file "~/.emacs.d/lisp/init-local.el")
  )

(provide 'init-evil)
;;; init-evil.el ends here
