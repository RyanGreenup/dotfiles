
;;; init-keybindings.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;; Keybindings are also contained in:

;; - ./init-evil.el
;;   - for evil stuff
;; - ./init-packages.el
;;   - for obvious bindings
;;; Code:

;;;; Helm
(global-set-key (kbd "C-x b") 'helm-buffers-list)
;;;; Org
;; (global-set-key (kbd "C-RET") (lambda () (message "Yeah It's working"))
(global-set-key (kbd "C-x w") 'count-words)
(global-set-key (kbd "C-c C-p C-p") 'texfrag-force-preview-at-point)
;;;; General and Global
(global-set-key (kbd "M-p")  'move-line-up)
(global-set-key (kbd "M-n")  'move-line-down)
;;;;; Adjust Fonts
(global-set-key (kbd "C-M-=") 'doom/increase-font-size)
(global-set-key (kbd "C-M-<mouse-4>") 'doom/increase-font-size)
(global-set-key (kbd "C-M-<mouse-5>") 'doom/decrease-font-size)
(global-set-key (kbd "C-M--") 'doom/decrease-font-size)

(add-hook 'org-mode-hook
  (lambda ()
    (local-set-key (kbd "C-M-<return>") 'org-copy-src-block)
  )
)

;;;;; Org Agenda
(global-set-key (kbd "C-c a") (lambda () (interactive) (org-agenda) (evil-emacs-state)))
(global-set-key (kbd "C-c A") '(lambda () (interactive) (my/org-super-agenda) (evil-emacs-state)))
(global-set-key (kbd "C-c v") 'my-open-current-file-in-vim)
;;;; Programming
;;;; C
(add-hook 'c-mode-hook
  (lambda ()
    (local-set-key (kbd "C-S-<return>") (lambda () (interactive) (compile "make -k run" nil)))
  )
)
;;;; R
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)
  (define-key flymake-mode-map (kbd "M-[") 'flymake-show-diagnostics-buffer)
  (define-key flymake-mode-map (kbd "M-]") 'flymake-goto-diagnostic)
)

(defun myR/tidyverse-pipe ()
  (interactive)
  (insert " %>% "))

(defun myR/assign ()
  (interactive)
  (insert " <- "))

(add-hook 'ess-mode-hook
  (lambda ()
    (local-set-key (kbd "C-S-r") 'Insert-R-Heading-1)
    (local-set-key (kbd "C-|") 'myR/tidyverse-pipe)
    (local-unset-key (kbd "M--"))
    (local-set-key (kbd "M--") 'myR/assign)
    (outshine-mode)
    (local-set-key (kbd "C-c h 1") 'Insert-R-Heading-1)
    (local-set-key (kbd "C-c h 2") 'Insert-R-Heading-2)
    (local-set-key (kbd "C-c h 3") 'Insert-R-Heading-3)
  )
)
;;;;;; Elisp
(add-hook 'emacs-lisp-mode-hook
  (lambda ()
    (local-set-key (kbd "M-RET") 'eval-last-sexp)
    (local-set-key (kbd "C-M-x") 'eval-region)
  )
)

;;;;;; Python

(defun python-mode-send-line-and-move-down ()
  (interactive)
  (setq last-command-event 5)
  (python-shell-send-statement nil t)
  (setq last-command-event 14)
  (next-line 1 1)
  (setq last-command-event 'f4))

(defun python-mode-send-line ()
  (interactive)
  (setq last-command-event 5)
  (python-shell-send-statement nil t)
  (setq last-command-event 'f4))


(add-hook 'python-mode-hook
  (lambda ()
    (local-set-key (kbd "M-RET") 'python-mode-send-line)
    (local-set-key (kbd "C-c C-n") 'python-mode-send-line-and-move-down)
    (local-set-key (kbd "C-RET") 'python-mode-send-line-and-move-down)
    (outshine-mode)
    ;; (run-python)
  )
  )


;;;; Markdown Mode
(add-hook 'markdown-mode-hook
  (lambda ()
;;;;;; Change Key Bindings for links
    (local-set-key (kbd "C-c C-x C-l") 'org-toggle-latex-fragment)
    (local-set-key (kbd "C-c C-x C-u") 'markdown-toggle-url-hiding)
  )
)










;;;; Org Mode
(add-hook 'org-mode-hook
  (lambda ()
;;;;;; Create Key Bindings for Link Store
    ;; See also (setq org-id-link-to-org-use-id t) enabled in init-org
    (local-set-key (kbd "C-c l") 'org-store-link)
    (local-set-key (kbd "C-c I") 'org-id-get-create)
  )
)


;;;; Programming

;;; Helper Functions


(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))


(defun my-edit-region-with-texmacs ()
  (interactive)
  (clipboard-kill-region (region-beginning) (region-end))
  (save-window-excursion
    (async-shell-command (format "~/bin/FixMathWithTexMacs.sh"))
  )
;;  (clipboard-yank)
)

(defun my-edit-clipboard-with-texmacs ()
  (interactive)
  (save-window-excursion
    (async-shell-command (format "xclip -selection clipboard -o | figlet | xclip -selection clipboard"))
  )
)





(defun my-take-screenshot ()
    (interactive)
    (let
        ;; Read Filename from Minibuffer
        ((filename (read-from-minibuffer "image file name: "))
        (directory "media"))

        ;; Use maim to screenshot
          ;; make directory
        (shell-command (format "mkdir -p %s/%s" default-directory directory))
          ;; Screenshot
        (shell-command (format "maim --select %s/%s/%s.png" default-directory directory filename ))

        ;; Insert formatted link at point
        (save-excursion (insert(format
        "#+attr_html: :width 400px \n #+attr_latex: :width 0.4\\textwidth \n [[file:%s/%s.png]]"
        directory filename)))

        ;; Message success to the minibuffer
        (message "saved to %s as %s.png" directory filename)
    )
)

(defun my-insert-clipboard-png ()
    (interactive)
    (let
        ;; Read Filename from Minibuffer
        ((filename (read-from-minibuffer "image file name: "))
        (directory "_media"))

        ;; Use maim to screenshot
        (shell-command (format "mkdir -p %s/%s" default-directory directory))
        (shell-command (format "xclip -selection clipboard -t image/png -o > %s/%s/%s.png" default-directory directory filename ))

        ;; Insert formatted link at point
        (save-excursion (insert(format
        "#+attr_html: :width 400px \n#+attr_latex: :width 0.4\\textwidth \n[[file:%s/%s.png]]"
        directory filename)))

        ;; Message success to the minibuffer
        (message "saved to %s as %s.png" directory filename)
    )
)

(defun org-copy-src-block ()
  (interactive)
  (org-edit-special nil)
  (mark-whole-buffer)
  (kill-ring-save 38 1 1)
  (org-edit-src-abort))




(provide 'init-keybindings)
;;; init-keybindings.el ends here
