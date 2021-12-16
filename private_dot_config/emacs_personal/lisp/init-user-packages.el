;;; init-user-packages.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
;;;; Set up straight

;;;; Set up Use Package
;; This is convenient for implementing other peoples configs and
;; having bindings and everything all together.  This also integrates
;; with straight
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;;;; Download Evil
(straight-use-package 'evil)
    (when (version< emacs-version "28")
    (message "undo-redo implemented in in Emacs 28, Emacs < 28 require undo-tree")
    (message "Currently using undo tree on all (for the very convenient tree)")
    )
    (straight-use-package 'undo-tree)
    (global-undo-tree-mode 1)
    (setq evil-undo-system 'undo-tree)

(straight-use-package 'evil-escape)
(straight-use-package 'fzf)

(straight-use-package 'avy)
(define-key global-map (kbd "C-c SPC") 'avy-goto-char-2)

;;;; Dokuwiki
(straight-use-package 'dokuwiki-mode)
(straight-use-package 'ox-wk) ;; MUST (load-library) and choose ox-wk
;;;; Org Stuff
(use-package texfrag
      :straight t
      :hook
      (after-init . texfrag-global-mode)
		      )

(straight-use-package 'org-super-agenda)
(straight-use-package 'org-superstar)
(straight-use-package 'writeroom-mode)
;;;;; Org Roam
(use-package org-roam
      :straight t
      :ensure t
      :custom
      (org-roam-directory "~/Notes/org-roam/pages/")
      :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-node-find)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-node-insert))
              (("C-c n I" . org-roam-insert-immediate))))
(straight-use-package 'org-ref) ;; does not declare autoloads! MUST
				;; use (require 'org-ref) somewhere
				;; (called in init-org)
(straight-use-package 'ivy-bibtex)
;;;;; Org Roam Server
(straight-use-package 'org-roam-server)

;;;;; Org Roam UI (Better org roam server)
;; https://github.com/org-roam/org-roam-ui#straightuse-package
(use-package org-roam-ui
  :straight
    (:host github :repo "org-roam/org-roam-ui" :branch "main" :files ("*.el" "out"))
    :after org-roam
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))
;;;;; Babel
(straight-use-package 'ob-go)
(straight-use-package 'go-mode)
;;;; Emacs Application Framework
;;;; Interface
;;;; Macros
(straight-use-package 'elmacro)
(elmacro-mode 1)
;;;;; Scrolling
(straight-use-package 'smooth-scrolling)    ;; Keep Point centred when using up/down on KB
;;;;; Helm
;; I still need a lot of the helm stuff for helm-org-rifle
;; however helm-mode breaks ess, so use ivy for that
(straight-use-package 'helm) 
;; Import when idle because it takes 0.2 seconds
;; (run-with-idle-timer 1 nil (lambda () (message "Enabled Helm Mode after Idle Time"))) 
;; (add-hook 'after-init-hook (lambda () (helm-mode 1)(message "Enabled Helm Mode after Idle Time")))
;;  ;; SLOW This takues 0.2 sec, 

;; (straight-use-package 'helm-swoop)
(straight-use-package 'helm-org-rifle)
(straight-use-package 'helm-org)
(straight-use-package 'helm-org-ql)
(straight-use-package 'helm-org-rifle)
(straight-use-package 'helm-rg)
(straight-use-package 'helm-unicode)

;;;;; Ivy
;; These are handled inside init-ivy.el just to
;; make my life easier

;;;;; Pop Win
(straight-use-package 'popwin)
(popwin-mode 1)

;;;; Themes
(straight-use-package 'dracula-theme)
(straight-use-package 'zenburn-theme)
(straight-use-package 'color-theme-sanityinc-tomorrow)
(straight-use-package 'faff-theme)
(straight-use-package 'lab-themes)
(straight-use-package 'flucui-themes)
(straight-use-package 'material-theme)
(straight-use-package 'leuven-theme)
(setq custom-safe-themes t)
(defun apply-elegance-style ()
  (interactive)
  (require 'elegance)
)

;;;; Beacon
(straight-use-package 'beacon)
(setq beacon-blink-when-window-scrolls nil)
(setq beacon-blink-when-window-changes t)
(setq beacon-blink-when-point-moves t)
(beacon-mode 1)

;;;; Notes
(straight-use-package 'markdown-mode)

;;;; Git
(straight-use-package 'magit)
(straight-use-package 'git-timemachine)
(straight-use-package 'git-gutter)
(global-git-gutter-mode +1)

;;;; Programming
(straight-use-package 'elmacro)
(straight-use-package 'ess)
(straight-use-package 'go-mode)
(add-hook 'go-mode-hook 'eglot-ensure)
(straight-use-package 'rust-mode)
(add-hook 'rust-mode-hook 'eglot-ensure)
(straight-use-package 'poly-R)
(straight-use-package 'hl-todo)
(straight-use-package 'highlight-indent-guides)
(global-hl-todo-mode 1)
;;;;; Neotree
(straight-use-package 'neotree)
(straight-use-package 'ranger)
(straight-use-package 'all-the-icons)
;;;;; YaSnippet
(straight-use-package 'yasnippet)
(straight-use-package 'ivy-yasnippet)
(straight-use-package 'yasnippet-snippets)
;; TODO look at auto expansion of snippets
;; https://github.com/joaotavora/yasnippet/issues/998
;;;;; Company Mode
(straight-use-package 'company)


;;;;; Company Mode
(straight-use-package 'company)
(setq company-tooltip-idle-delay 1)              ;; This can cause slow downs
(setq company-idle-delay 1)                      ;; on a lean emacs it's really nice though
(global-company-mode)
;;;;;; Fuzzy
;; (straight-use-package 'company-fuzzy)
;; (straight-use-package 'flx)
;; (setq company-fuzzy-sorting-backend 'flx)
;; (setq company-require-match nil) ;; this needs to be disabled for fuzzy to make sense
;; (global-company-fuzzy-mode 1)
;;;;; eglot
(straight-use-package 'eglot)
(straight-use-package 'c-eldoc)


(add-hook 'c-mode-hook (lambda ()
	      (eglot-ensure) (when (require 'helm nil 'noerror)
	      (helm-mode -1)
	      )
	    )
	  )
(add-hook 'python-mode-hook 'eglot-ensure)
(add-hook 'julia-mode-hook '(lambda () (eglot-jl-init) (eglot-ensure)))
(add-hook 'ess-r-mode-hook (lambda ()
			     (eglot-ensure)  
			     (when (require 'helm nil 'noerror)
			       (helm-mode -1)
			       )
			     )
	  )      ;; helm-mode breaks ess-r so disable it
;; (add-hook 'prog-mode-hook 'eglot-ensure)
(add-hook 'prog-mode-hook 'hs-minor-mode)
(add-hook 'prog-mode-hook 'outshine-mode)
;;;;; YaSnippet
(straight-use-package 'yasnippet)
(straight-use-package 'yasnippet-snippets)


;;;;; Dumb Jump
(straight-use-package 'dumb-jump)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
;;;;; Julia Stuff
(straight-use-package 'eglot-jl)
(straight-use-package 'ob-ess-julia)
(straight-use-package 'shell)
(straight-use-package 'julia-mode)
(add-to-list 'auto-mode-alist '("\\.jl\\'" . ess-julia-mode))


;;;; Modeline
;;;;; Doom
;; (straight-use-package 'doom-modeline)
;; (straight-use-package 'all-the-icons)
;; (straight-use-package 'minions)
;;;;; Spacemacs
;; See ./init-spacemacs-modeline.el
;; If I decide not to use it I may as well not load these
;;;; Shell
(straight-use-package 'vterm)

;;;; Profiling
(straight-use-package 'esup)

;;;; Keybindings
;;;; Which Key
(straight-use-package 'which-key)
;;;;; Hydra
(straight-use-package 'hydra)

;;;; Outshine Mode
(straight-use-package 'outshine)
(add-hook 'prog-mode-hook '(lambda () (outshine-mode 1)))

;;; Golden Ratio Mode
(straight-use-package 'golden-ratio)
			     (golden-ratio-mode 1)			;; Enable to set commands
			     (setq golden-ratio-extra-commands
				    (append golden-ratio-extra-commands
					    '(evil-window-left
						evil-window-right
						evil-window-up
						evil-window-down
						select-window-1
						select-window-2
						select-window-3
						select-window-4
						select-window-5)))	;; Set to work with Evil
			     (setq golden-ratio-mode nil)		;; Disable because it's annoying


(provide 'init-user-packages)
;;; init-user-packages.el ends here
