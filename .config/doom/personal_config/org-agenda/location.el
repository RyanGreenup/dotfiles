;;; personal_config/org-agenda/location.el -*- lexical-binding: t; -*-

;;; Set org mode Agenda stuff
;;;; Variables
(setq my/tasks_dir "~/Agenda/")
(setq my/notes_dir "~/Notes/slipbox")
;; (setq my/journal_dir (concat my/notes_dir "/journals/"))
(setq my/tasks_list (concat my/tasks_dir "todo.org"))
;; Todays journal will have the last name using rfc3339 ⊂ iso-8601
;; (setq todays_journal
;;       (format (concat my/journal_dir "%s")
;;               (car (last (directory-files my/journal_dir)))))
;; Set the initial buffer
;; (setq initial-buffer-choice todays_journal)

;;;; Agenda Files
(setq org-directory my/tasks_dir)
;;(setq org-agenda-files (list my/tasks_dir)) ; NOTE clocking in will open ALL org-agenda-files
                                        ; ;; https://github.com/doomemacs/doomemacs/issues/5317
(setq org-agenda-files (list
                        "~/Agenda/todo.org"
                        "~/Agenda/inbox.org"
                        "~/Agenda/work.org"
                        "~/Notes/rs_wiki/Agenda/rs_cal.org"
                        "~/Notes/rs_wiki/Agenda/rs_shopping.org"
			"~/Agenda/calendar.org"
                        ))
