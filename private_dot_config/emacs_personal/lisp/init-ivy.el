;;; init-ivy.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Straight Packages
(straight-use-package 'ivy)
(straight-use-package 'counsel)
(straight-use-package 'swiper)
(straight-use-package 'ivy-posframe)

;;; Code:
;;;; M-x
(global-set-key (kbd "M-x") 'counsel-M-x)

;;;; Evil Bindings

;;;;; Swoop

(evil-define-key 'normal 'global (kbd "<leader>ss") 'swiper)

;;;;; Bookmarks
(evil-define-key 'normal 'global (kbd "<leader><return>") 'counsel-bookmark)


;;;;; Files
(evil-define-key 'normal 'global (kbd "<leader>ff") 'counsel-find-file) ; Use ivy
(evil-define-key 'normal 'global (kbd "<leader>fr") 'consult-recent-files) ;; use ivy
(straight-use-package 'ivy-posframe)
(ivy-posframe-mode)

;;;;; PosFrame
(evil-define-key 'normal 'global (kbd "<leader>/") 'counsel-rg)
(evil-define-key 'normal 'global (kbd "<leader>fz") 'counsel-fzf)
(evil-define-key 'normal 'global (kbd "<leader>ff") 'counsel-find-file) 
(evil-define-key 'normal 'global (kbd "<leader>fr") 'counsel-buffer-or-recentf)

;;;;; Posframe 
(straight-use-package 'ivy-posframe)
;;;;;; Position
(setq ivy-posframe-display-functions-alist
      '((swiper          . ivy-posframe-display-at-point)
        (complete-symbol . ivy-posframe-display-at-point)
        (counsel-M-x     . ivy-posframe-display-at-frame-top-center)  ;; Make it like VS Code just for consistency
        (complete-fzf    . ivy-posframe-display-at-frame-top-center)
        (t               . ivy-posframe-display-at-frame-top-center)))
;;;;;; Size
(setq ivy-posframe-height-alist '((swiper . 15)
                                  (t      . 20)))
(ivy-posframe-mode 1)

;;;;;; Alternative Positions
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-center)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-bottom-left)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-window-bottom-left)))
;; (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center)))


;;;; Counsel themes
;; https://oremacs.com/2015/06/23/counsel-load-theme/
;;;;; load theme action
(defun counsel--load-theme-action (x)
  "Disable current themes and load theme X."
  (condition-case nil
      (progn
        (mapc #'disable-theme custom-enabled-themes)
        (load-theme (intern x))
        (when (fboundp 'powerline-reset)
          (powerline-reset)))
    (error "Problem loading theme %s" x)))

;;;;; load theme
(defun counsel-load-theme ()
  "Forward to `load-theme'.
Usable with `ivy-resume', `ivy-next-line-and-call' and
`ivy-previous-line-and-call'."
  (interactive)
  (ivy-read "Load custom theme: "
            (mapcar 'symbol-name
                    (custom-available-themes))
            :action #'counsel--load-theme-action))

;;;;; set keybinding
;; this is buggy
;; (evil-define-key 'normal 'global (kbd "<leader>ht") 'counsel-load-theme) ;; see init-ivy

;;;; Counsel org-tags
(add-hook 'org-mode-hook
	  (lambda () (define-key org-mode-map (kbd "C-c C-q") 'counsel-org-tag)))

;;; end
(ivy-mode 1)
(provide 'init-ivy)
;;; init-ivy.el ends here
