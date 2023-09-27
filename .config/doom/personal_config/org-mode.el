;;; personal_config/org-mode.el -*- lexical-binding: t; -*-


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
