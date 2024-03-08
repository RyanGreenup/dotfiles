

(defun ryan_agenda()
  "launch org-agenda for ryan_new_Agenda."
  (interactive)
  (setq org-agenda-files '("~/ryan_new_Agenda/monash.org"
                           "~/ryan_new_Agenda/dsa.org"
                           "~/ryan_new_Agenda/todo.org"
                           "~/Notes/rs_wiki/Agenda/rs_cal.org"))
  (org-agenda nil "a"))
(global-set-key (kbd "C-c r") 'ryan_agenda)

(defun shai_agenda()
  "launch org-agenda for ryan_new_Agenda."
  (interactive)
  (setq org-agenda-files '("~/Agenda/todo.org"
                           "~/Agenda/inbox.org"
                           "~/Notes/rs_wiki/Agenda/rs_cal.org"
                           "~/Notes/rs_wiki/Agenda/rs_shopping.org"
                           ))
  (org-agenda nil "a"))
(global-set-key (kbd "C-c s") 'shai_agenda)
