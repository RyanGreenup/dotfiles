;;; personal_config/org-agenda/functions.el -*- lexical-binding: t; -*-


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




;;;; Agenda overview
(defun agenda-overview ()
  (interactive)
  (org-agenda-list 90)
  (evil-window-vsplit nil nil)
  (evil-window-vsplit nil nil)
  (evil-window-vsplit nil nil)
  (evil-goto-first-line nil)
;;;; Agenda Custom Commands
;; https://stackoverflow.com/questions/17003338/emacs-org-mode-how-to-find-all-todos-that-dont-have-a-deadline-specified
(setq org-agenda-custom-commands
`(;; match those tagged with :inbox:, are not scheduled, are not DONE.
        ("is" "Unscheduled tasks" tags "-SCHEDULED={.+}/!+TODO|+STARTED|+WAITING")
        ("id" "No Deadline" tags "-SCHEDULED={.+}/!+TODO|+STARTED|+WAITING")
        )
)
  ;; (org-agenda-toggle-time-grid)
  (require 'follow)
  (follow-redraw))
;;;;; Calfw
(defun my/org-calendar ()
  (interactive)
        (require 'calfw)
        (require 'calfw-cal)
        (require 'calfw-org)
        (cfw:open-org-calendar))
