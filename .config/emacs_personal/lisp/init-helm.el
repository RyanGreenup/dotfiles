;;; init-helm.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(global-set-key (kbd "M-x") 'helm-M-x)
(evil-define-key 'normal 'global (kbd "<leader>ff") 'helm-find-files) ; Use helm
(setq helm-swoop-pre-input-function (lambda () ""))
(setq helm-follow-mode-persistent t)
(evil-define-key 'normal 'global (kbd "<leader>fF") 'my/helm-find-file-recursively) 
(evil-define-key 'normal 'global (kbd "<leader>fr") 'helm-recentf) ;; use helm
(evil-define-key 'normal 'global (kbd "<leader>ss") 'helm-swoop)
(setq helm-swoop-speed-or-color t) ;; SLOW ?
(evil-define-key 'normal 'global (kbd "<leader><return>") 'helm-filtered-bookmarks)
(global-set-key (kbd "C-x r l") 'helm-filtered-bookmarks)


(defun my/helm-find-file-recursively ()  
  (interactive)
  "Recursively find files in glob manner, in the specified directory."
  (helm-find 'ask-for-dir))

(global-set-key (kbd "C-c o f") 'my/helm-find-file-recursively)


(provide 'init-helm)
;;; init-helm.el ends here
