;; set org agenda files
(setq org-agenda-files (list "~/Agenda/todo.org"
                             "~/Agenda/projects.org"
                             "~/Agenda/habits.org"))

;; set keyboard shortcut for org-agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;; run org agenda at startup and full screen
;; (add-hook 'after-init-hook (lambda () (org-agenda nil "a")))
(org-agenda nil "a") ; nil: means run org-agenda with no window splitting
                   ; a:   show the agenda view.


(org-agenda-list)  ;; List the Agenda
(switch-to-buffer) ;; Change back from the splash

