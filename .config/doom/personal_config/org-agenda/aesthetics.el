;;; personal_config/org-agenda/aesthetics.el -*- lexical-binding: t; -*-

;; https://emacs.stackexchange.com/questions/28905/color-specific-days-in-different-background-in-org-agenda
;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Face-Attributes.html
(defun my-org-agenda-get-day-face-fn (date)
  "Return the face DATE should be displayed with."
  (let ((day-of-week (calendar-day-of-week date)))
    (cond
     (
      '(:height 160 :family "Fira Sans"
        ;;          :box (:line-width (5 . 1) :color "red" :style "bold")
        :underline (:color "indianred" :style line)
        :inverse-video nil
        :foreground "royalblue"
        )

      ))))

(setq org-agenda-day-face-function 'my-org-agenda-get-day-face-fn)
;;; Misc Hooks etc
(setq org-logseq-dir "~/Notes/slipbox")
(map! :leader
      :desc "Open Logseq Contents" "l c" #'org-logseq-toggle-contents-sidebar)
(after! org
  (setq
   org-agenda-span 7
   ;; org-agenda-start-day "-3d"
   org-agenda-start-on-weekday 1 ; 0 is sunday, 1 is monday ...
   calendar-week-start-day     1 ; What the first day of subsequent agenda views is
   org-agenda-start-on-weekday nil)
  (setq org-tags-column 80))


;;  (setq org-agenda-time-grid
;;          '((daily today weekly require-timed)
;;          (800 900 1000 1200 1300 1400  1500 1600 1700 1800 1900 2000)
;;          "......" "----------------"))
;; See also
;; (require 'calfw-org)


;; Display the Time grid for every day of the week
;; Change weekly to daily for the original value
;; Toggle in Agenda with G, v g or M-x org-agenda-toggle-time-grid
;; [[help:org-agenda-time-grid]]
(setq org-agenda-time-grid
      '((weekly today require-timed)
        (800 1000 1200 1400 1600 1800 2000)
        " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
