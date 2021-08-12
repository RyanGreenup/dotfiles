;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; This file bootstraps the configuration, which is divided into
;; a number of other files.
;; See https://github.com/purcell/emacs.d/blob/bf65ab24cb31a32add371a7bad5d391d02b5391d/init.el

;;; Code:
;; Set the load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;;;; Garbage Collect and startup hacks at Idle
(require 'init-startup-gc)

;;;; Produce backtraces when errors occur: can be helpful to diagnose startup issues
(setq debug-on-error t)


;;;; Load Package Manager
(require 'init-straight)

    ;; (require 'init-elpa)

    (defun display-startup-echo-area-message ()
      (print-time-delta)
      )


(defun print-time-delta ()
  "Print the Difference in time from now and before init time."
  (interactive)
(message (format "Init Time:\n---> %s\n Final Startup Time (post after-init-hook):\n---> %s\n"
		     (float-time (time-subtract after-init-time before-init-time))
		     (float-time (time-subtract (current-time) before-init-time))
		)
    )
  )


;;;; Load all packages
    (require 'init-user-packages)
    (require 'init-keybindings)
    (require 'init-change-theme-timer)

;;;; Interface
;;;;;; Which key
(require 'init-which-key)
;;;;;; Scrolling
    ;; scroll one line at a time (less "jumpy" than defaults)
(require 'init-smooth-scrolling)

;;;;;; Configure Evil
    (require 'init-evil)
    (winner-mode 1) 

;;;;;; Configure Helm
    ;; (require 'init-helm)
    (require 'init-ivy)

;;;;;; Popup Scratch Buffer
    (require 'init-popup-scratch)

;;;;;; Open in External program
(require 'init-open-in-external-program)
;;;;;; Adjust font
(require 'init-fonts)
;;;; Configure LaTeX Mode
(require 'init-latex)
;;;; Configure Org Mode
(require 'init-org)

;;;; Programming
(require 'init-ess)
(require 'init-singular)
(require 'init-programming-mode)
;;;; Set default font and apply theme
	;; Set Theme
	(set-theme-for-time-of-day)
;;;; Hydra
(require 'init-hydra)

    ;; Auto Save
    ;; Save when actually idle, this may get annoying though
    ;; (run-with-idle-timer 5 t 
    ;; 		     (lambda ()
    ;; 		       (save-buffer)
    ;; 		       (message "Saved")
    ;; 		       )
    ;; 		     )
    ;; compile hook
    ;; (add-hook 'after-save-hook '(lambda () (byte-recompile-directory "~/.emacs.d/lisp")) t t)






;;;; Run once When Idle (Trivial Things Only)
;;;;; 1 Second
(set 'default-font "Fira Code-10")
(run-with-idle-timer 1 nil
    (lambda ()
	(evil-escape-mode 1)			;; ~0.1 s
	(message "Idle Timer 1 Second: Begining Post Initialisation Modifications")
						;; (set-frame-font "Roboto Mono-10" nil t)
	(set-frame-font default-font nil t)	;; ~ 0.1 s
						;; (set-frame-font "monofur-10" nil t)
						;; (set-frame-font "Source Code Pro-10" nil t)
						;; Toggle scroll bar and Toolbar 
	(toggle-scroll-bar -1)			;; ! 0.1 s
	(tool-bar-mode -1)			;; ! 0.1 s
        (menu-bar-mode -1)                      ;; I like the Menus actually so toggle with <SPC t SPC>
    )
    )


(add-to-list 'default-frame-alist `(font . ,default-font)) ;; Use backquote and comma https://stackoverflow.com/questions/1664202/emacs-lisp-evaluate-variable-in-alist

;;;;; 3 Second
;; Load Org mode so it's ready after some delay

(defvar init-org-idle-load 3)
(run-with-idle-timer init-org-idle-load nil
		     (lambda ()
		       (message "\n---\nIdle Timer of %s seconds:\n\t Loading Org\n---\n" init-org-idle-load)
		       ;; Load Org-Mode + Index and Todo
		       (find-file-noselect "~/Notes/Org/index.org")
		       (find-file-noselect "~/Notes/Org/agenda/todo.org")
		       ;; Build Agenda
			 (org-agenda-list)
			 (delete-window)
		       ;; Load Yasnippet
			 (yas-global-mode 1)
		       )
		     )

;;;;; Modeline 
(require 'init-telephone-line)        ;; Loads Quick and feels fine

;; (require 'init-spacemacs-modeline) ;; takes 1.2 seconds at startup
;; (require 'init-doom-modeline)      ;; FIXME The doom modeline cripples
				      ;; the performance of org-mode
				      ;; files, this can be seen by a
				      ;; side by side comparison of two
				      ;; org files using follow mode, one
				      ;; without the modeline.

(run-with-idle-timer 3 nil (lambda ()
;; EMPTY
)
)


;; This gets annoying so turn it off after launch
(setq debug-on-error nil)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-source-names-using-follow
   '(#("argv: /usr/bin/rg --smart-case --color=ansi --colors=match:fg:red --colors=match:style:bold bound" 6 17
       (face helm-rg-base-rg-cmd-face)
       18 30
       (face helm-rg-active-arg-face)
       31 43
       (face helm-rg-inactive-arg-face)
       44 65
       (face helm-rg-inactive-arg-face)
       66 91
       (face helm-rg-inactive-arg-face)
       92 97
       (face font-lock-string-face))
     "Buffers")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


