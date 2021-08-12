;;; init-org-super-agenda.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;; Definitely look at the examples
;; https://github.com/alphapapa/org-super-agenda/blob/master/examples.org#books-to-read
;;; Code:
(defun my/org-super-agenda ()
  "Create a super agenda with categories and stuff"
  (interactive)
  (enable-org-super-agenda-if-necessary)
  (let
      ((org-super-agenda-groups
	'(;; Each group has an implicit boolean OR operator between its selectors.
	  (:name "Today"	  ; Optionally specify section name
                 :time-grid t	  ; Items that appear on the time grid
                 :todo "TODAY")
					; Items that have this TODO keyword
	  (:name "Important"
                 ;; Single arguments given alone
                 :tag "bills"
                 :priority "A")
	  ;; Set order of multiple groups at once
	  (:order-multi
	   (3
	    (:name "School Related"
                   :habit t
                   :tag "university")
	    (:name "Home Computer Maintenance"
                   ;; Boolean AND group matches items that match all subgroups
                   :and
		   (:tag "computers" :tag "@home"))
	    (:name "Home and Weekend"
                   ;; Multiple args given in list with implicit OR
                   :tag
		   ("@home" "evening"))
	    (:name "Personal Studies"
                   ;; Regexps match case-insensitively on the entire entry
                   :and
		   (:regexp
		    ("notetaking" "revision")
		    ;; Boolean NOT also has implicit OR between selectors
                    :not
		    (:regexp "zzz" :tag "university"))))
	   (:name "Notes, Recollection and Knowledge Base"
                  :habit t
                  :tag "notetaking")
	   )
	  ;; Groups supply their own section names when none are given
	  (:todo "NEXT" :order 2)
					; Set order of this section
	  (:todo "WAITING" :order 8)
					; Set order of this section
	  (:todo
	   ("SOMEDAY" "TO-READ" "CHECK" "TO-WATCH" "WATCHING")
	   ;; Show this group at the end of the agenda (since it has the
           ;; highest number). If you specified this group last, items
           ;; with these todo keywords that e.g. have priority A would be
           ;; displayed in that group instead, because items are grouped
           ;; out in the order the groups are listed.
           :order 9)
	  (:priority<= "B"
                       ;; Show this section after "Today" and "Important", because
                       ;; their order is unspecified, defaulting to 0. Sections
                       ;; are displayed lowest-number-first.
                       :order 1)
	  ;; After the last group, the agenda will display items that didn't
          ;; match any of these groups, with the default order position of 99
          )))
    (org-agenda nil "a"))
  )
(defun enable-org-super-agenda-if-necessary ()
  (if (not (bound-and-true-p org-super-agenda-mode))
      (org-super-agenda-mode 1)))
(provide 'init-org-super-agenda)
;;; init-org-super-agenda.el ends here
