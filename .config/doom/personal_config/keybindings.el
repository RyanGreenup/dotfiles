;;; personal_config/keybindings.el -*- lexical-binding: t; -*-

;;; Org Mode
;;;; Agenda
(map!
 "C-c a" 'org-agenda)
;;;; Open Tasks
;; (global-set-key (kbd "<f1> j") 'my/open_todays_journal)
;; (global-set-key (kbd "<f1> t") 'my/open_tasks)
(map! :leader
      :desc "Open Todays journal" "<f2> t" 'my/open_tasks)
(map! :leader
      :desc "Open Todays journal" "<f2> j" 'my/open_todays_journal)
(map! :leader
      :desc "Open Todays journal" "<f2> n" 'my/notes-find)
;;; General
;;;; Open in Vim
(defun my/open-current-file-in-vim ()
  (interactive)
  (async-shell-command
   (format "alacritty -e nvim +%d %s"
           (+ (if (bolp) 1 0) (count-lines 1 (point)))
           (shell-quote-argument buffer-file-name))))
(map!
     "C-c v"    #'my/open-current-file-in-vim)
;;;; Easier window changing
;; https://github.com/syl20bnr/spacemacs/issues/5933
;; https://www.reddit.com/r/emacs/comments/kftv15/doom_emacs_problems_rebinding_keys/
(map!
     :map evil-motion-state-map
 "C-k" 'evil-window-up)
(map!
     :map evil-motion-state-map
 "C-h" 'evil-window-left)
(map!
     :map evil-motion-state-map
 "C-l" 'evil-window-right)
(map!
     :map evil-motion-state-map
 "C-j" 'evil-window-down)
;;; Languages
;;;; R
;; ~/.config/doom/config.el
(map!
     :map ess-mode-map
     "<M-return>" #'ess-eval-region-or-function-or-paragraph
     "<S-return>" #'ess-eval-region-or-function-or-paragraph-and-step)

