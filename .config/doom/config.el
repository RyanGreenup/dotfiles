;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/Agenda/")
(setq org-agenda-files (list "~/Agenda" "~/Notes/slipbox/journals"))


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;;; Set org mode Agenda stuff
;;;; Variables
(setq my/tasks_dir "~/Agenda/")
(setq my/notes_dir "~/Notes/slipbox")
(setq my/journal_dir (concat my/notes_dir "/journals/"))
(setq my/tasks_list (concat my/tasks_dir "todo.org"))
;; Todays journal will have the last name using rfc3339 ⊂ iso-8601
(setq todays_journal
      (format (concat my/journal_dir "%s")
              (car (last (directory-files my/journal_dir)))))
;; Set the initial buffer
;; (setq initial-buffer-choice todays_journal)

;;;; Agenda Files
(setq org-directory my/tasks_dir)
(setq org-agenda-files (list my/tasks_dir my/journal_dir))
;;;; Functions
;; Journal
(defun my/open_todays_journal ()
  (interactive)
  (find-file todays_journal))
;; Tasks
(defun my/open_tasks ()
  (interactive)
  (find-file my/tasks_list))
;; Notes
(defun my/open_notes ()
  (interactive)
  (desktop-change-dir my/notes_dir)
  (find-file)
  )
(defun my/notes-find ()
 (interactive)
  ;; Built in way
 (find-file "~/Notes/slipbox/pages/" )
 (+default/find-file-under-here)
  ;; Projectile way
 (projectile-find-file-in-directory "~/Notes/slipbox/pages"))
;;;; Keybindings
;;;;; General Emacs
;; (global-set-key (kbd "<f1> j") 'my/open_todays_journal)
;; (global-set-key (kbd "<f1> t") 'my/open_tasks)
;;;;; Doom
(map! :leader
      :desc "Open Todays journal" "<f2> t" 'my/open_tasks)
(map! :leader
      :desc "Open Todays journal" "<f2> j" 'my/open_todays_journal)
(map! :leader
      :desc "Open Todays journal" "<f2> n" 'my/notes-find)
;;; Misc Hooks etc
(setq org-logseq-dir "~/Notes/slipbox")
(map! :leader
      :desc "Open Logseq Contents" "l c" #'org-logseq-toggle-contents-sidebar)
(after! org
  (setq org-agenda-span 10
        org-agenda-start-on-weekday nil
        org-agenda-start-day "-3d")
  (setq org-tags-column 80))

 (setq org-agenda-time-grid
         '((daily today weekly require-timed)
         (800 900 1000 1200 1300 1400  1500 1600 1700 1800 1900 2000)
         "......" "----------------"))
;; See also
;; (require 'calfw-org)

;;; Easier window changing
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

(map!
 "C-c a" 'org-agenda)

;;;;; Enable TexFrag Mode
;; Texfrag mode is way faster and looks nicer so use that instead
(add-hook 'org-mode-hook
  (lambda ()
    (texfrag-mode)
  )
)
(add-hook 'markdown-mode-hook
  (lambda ()
    (texfrag-mode)
  )
)
(add-hook 'dokuwiki-mode-hook
  (lambda ()
    (texfrag-mode)
  )
)

;;; Set up a load path
(setq doom-config-directory "~/.config/doom")
(add-to-list 'load-path (expand-file-name "lisp" doom-config-directory))

;;; Org Ref Stuff
(require 'init-org-ref)

;;; Configure Org Super Agenda
(require 'init-org-super-agenda)
(map!
 "C-c A" 'my/org-super-agenda)


;;; Configure icalendar ics export
(setq org-icalendar-include-todo t
      org-icalendar-use-deadline '(event-if-todo event-if-not-todo todo-due)
      org-icalendar-use-scheduled '(event-if-todo event-if-not-todo todo-start)
      org-icalendar-with-timestamps t)
(setq org-icalendar-alarm-time 0)

(setq org-caldav-url "http://localhost:8925/remote.php/dav/calendars/ryan")
(setq org-caldav-calendar-id "org-mode-3")
(setq org-caldav-inbox "~/Agenda/inbox.org")
(setq org-caldav-files '("~/Agenda/todo.org" "~/Agenda/someday_maybe.org" "~/Agenda/Reading_List.org" "~/Agenda/projects.org"))
(setq org-caldav-sync-changes-to-org 'all) ;; must be set as 'all or timestamp won't sync org <- cal, use gitui and stage changes first
                                           ;; e.g. using (my/org-caldav-sync)
(setq org-caldav-delete-calendar-entries 'always)
(setq org-caldav-backup-file "/tmp/caldav-backup.org")
;; C-u M-x org-caldav-delete-everything
;; Helper function to prevent mistakes
(defun my/org-caldav-sync ()
  (interactive)
  (setq my/agenda-dir "$HOME/Agenda")
  ;; Stage the git repo to detect changes related to sync
  ;; Or should I stash?
  (if
    (shell-command (format "cd %s && git add -u" my/agenda-dir))
      (message (format  "Staged changes under %s" my/agenda-dir))
      (message (format  "Warning: Unable to changes under %s" my/agenda-dir)))  (org-caldav-sync)
  ;; Perform the sync
  (org-caldav-sync)
  ;; Save the buffers
  (org-save-all-org-buffers))

;; ~/.config/doom/config.el
(map!
     :map ess-mode-map
     "<M-return>" #'ess-eval-region-or-function-or-paragraph
     "<S-return>" #'ess-eval-region-or-function-or-paragraph-and-step)

(defun clever-math()
  (interactive)
  (major-mode-suspend)
  (markdown-mode)
  (texfrag-document)
  (read-string "Press Enter when Math Appears (this is a hack)")
  (major-mode-restore))
(map!
     :map dokuwiki-mode-map
     "<backtab>" #'outline-cycle-buffer
     "<tab>"     #'outline-cycle
     "<return>"  #'outline-toggle-children
     "M-<right>" #'outline-demote
     "M-<left>"  #'outline-promote)
