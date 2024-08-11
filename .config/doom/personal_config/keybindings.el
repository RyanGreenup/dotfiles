;;; personal_config/keybindings.el -*- lexical-binding: t; -*-

;;; Org Mode
;;;; Agenda
(map!
 "C-c a" 'org-agenda)

;; https://github.com/doomemacs/doomemacs/issues/2192
(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :m "s" #'org-agenda-schedule)
(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :m "c" #'org-agenda-log-mode)



(defun my/org-agenda-filter-by-tag-with-prefix-arg ()
  (interactive)
  (let

      (defun my/org-agenda-filter-by-tag
          (org-agenda-filter-by-tag 0))
    (setq current-prefix-arg '(4)) ; C-u
    (call-interactively (lambda (p) (interactive "P") (org-agenda-filter-by-tag 0) ))))
(map!
 :map org-agenda-mode-map
 ;; Easier reschedule
 "C-i"         #'org-agenda-schedule
 "s"           #'org-agenda-schedule
 ;; Reschedule Day
 "M-<right>"    #'org-agenda-do-date-later
 "M-<left>"     #'org-agenda-do-date-earlier
 ;; Reschedule Hour
 "M-S-<right>"    (lambda (p) (interactive "P") (org-agenda-do-date-later '(4)) )
 "M-S-<left>"     (lambda (p) (interactive "P") (org-agenda-do-date-earlier '(4)) )
 ;; Reschedule Minute
 "C-M-<right>"    (lambda (p) (interactive "P") (org-agenda-do-date-later '(16)) )
 "C-M-<left>"     (lambda (p) (interactive "P") (org-agenda-do-date-16 '(earlier)) )
 "C-t"            (lambda (p) (interactive "P") (org-agenda-filter-by-tag 0) )
 )
;;;; Open Tasks
;; (global-set-key (kbd "<f1> j") 'my/open_todays_journal)
;; (global-set-key (kbd "<f1> t") 'my/open_tasks)
;; (map! :leader
;;       :desc "Open Todays journal" "<f2> t" 'my/open_tasks)
;; (map! :leader
;;       :desc "Open Todays journal" "<f2> j" 'my/open_todays_journal)
;; (map! :leader
;;       :desc "Open Todays journal" "<f2> n" 'my/notes-find)
(map! :leader
      :desc "Open Todays journal" "<f2> j" #'open-latest-journal-page)

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
