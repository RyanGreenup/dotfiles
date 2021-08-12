;;; init-programming-mode.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
;; Observe that YAs isn't loaded unless it is first triggered with it's binding C-S-SPC
;; This is because it takes 0.3 seconds to load, I've put it in the idle timer section


;; (add-hook 'prog-mode-hook  #'after-prog) ;; TODO This is triggered too early

;;; Company
    (global-unset-key (kbd "C-SPC"))
    (global-set-key (kbd "C-SPC") 'company-complete)
    (global-set-key (kbd "C-S-SPC") 'ivy-yasnippet-and-load)
    (global-set-key (kbd "C-c s") 'company-yasnippet) 
    (setq company-tooltip-idle-delay 0)              ;; This can cause slow downs
    (setq company-idle-delay 0)                      ;; on a lean emacs it's really nice though
    (global-company-mode 1)

    ;; (global-company-fuzzy-mode 1)
;;;;; Fuzzy
;; NOTE This breaks commpany-yasnippet, remove all company-fuzzy to
;;      restore that behaviour
    ;; (setq company-fuzzy-sorting-backend 'flx)
    ;; (setq company-require-match nil) ;; this needs to be disabled for fuzzy to make sense
    ;; (global-company-fuzzy-mode 1)
;;;; YaSnippet
    (defun ivy-yasnippet-and-load ()
    (interactive)
    (enable-yasnippet-if-necessary)
    (ivy-yasnippet)
    )
    (defun enable-yasnippet-if-necessary ()
    (if (not (bound-and-true-p yas-global-mode))
	(yas-global-mode 1)))

;;;; Hooks
(add-hook 'c-mode-hook 'eglot-ensure)
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


(provide 'init-programming-mode)
;;; Tabs and spaces
;; I think tabs make sense but whatever PEP 8 wins
(add-hook 'python-mode-hook (lambda ()
			      (setq indent-tabs-mode nil)
			      ))
;;; init-programming-mode.el ends here



