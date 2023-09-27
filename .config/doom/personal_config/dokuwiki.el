;;; personal_config/dokuwiki.el -*- lexical-binding: t; -*-


;;; Dokuwiki stuff
(defun clever-math()
  (interactive)
  (major-mode-suspend)
  (markdown-mode)
  (texfrag-document)
  (read-string "Press Enter when Math Appears (this is a hack)")
  (major-mode-restore))

(defun my-dw/open-link()
  (interactive)
        (setq link (thing-at-point 'sexp))
        (setq link (format "%s.txt" link))
        (find-file link)
        (dokuwiki-mode))

(defun my/select-inside-brackets()
  (interactive)
   ;; https://stackoverflow.com/questions/11280565/emacs-lisp-extract-number-under-point-between-two-brackets
   (setq page (when (re-search-forward "\\[\\([0-9]+\\)\\]" nil t)
  (string-to-number (match-string 1))))
   (message page))

(defun my-dw/open-link()
  (interactive)
        (setq link (thing-at-point--read-from-whole-string 'sexp))
        (setq link (format "%s.txt" link))
;;        (find-file link)
        (setq page (shell-command-to-string (format  "fd -H txt ~/Notes/dokuwiki/data/pages  | fzf --filter='%s' | head -n 1 | tr -d '\n'" link)))
        (message page)
       ;; (find-file page)
        )

(defun my/insert-link()
  (interactive)
  ;; make relative path
  ;; then replace '/' with ':'
  ;; for dokuwiki
  ;; (setq page (shell-command-to-string "cd ~/Notes/dokuwiki/data/pages; fd -H txt  |  dmenu -i -f -l 30 | sed 's#\.txt$##' | tr -d '\./' | tr -d '\n'"))

  ;; for gollum
  (setq page (shell-command-to-string "cd ~/Notes/slipbox; fd -H  |  dmenu -i -f -l 30 | sed 's#\.txt$##' |  tr -d '\n'"))
  (insert (format "[[:%s]]" page)))


(defun my-find-link ()
  (interactive)
  (setq last-command-event 118)
  (evil-visual-char nil nil 'inclusive t)
  (setq last-command-event 91)
  (evil-inner-bracket nil 152 153 'inclusive)
  (setq last-command-event 121)
  (evil-yank 135 153 'inclusive nil nil)
  (setq last-command-event 'f4))

(defun dokuwiki-insert-heading ()
  (interactive)
  (setq n (- 7 (read-number "Enter Heading Level: ")))
 (insert (format "%s %s %s"
                 (make-string n ?=)
                 (read-string "Enter Heading: ")
                 (make-string n ?=))))


(defun dokuwiki-demote ()
  (interactive)
  (delete-forward-char 1 nil)
  (move-end-of-line 1)
  ((lambda
     (&rest args)
     (interactive "p\nP")
     args)
   1 nil)
  (delete-backward-char 1 nil)
  (doom/backward-to-bol-or-indent
   (point)))

(defun dokuwiki-promote ()
  (interactive)
  (move-beginning-of-line 1)
  (outline-show-entry)
  (move-beginning-of-line 1)
  (insert "=")
  (move-end-of-line 1)
  (insert "=")
  (move-beginning-of-line 1)
  (outline-hide-entry))


(defun dokuwiki-demote ()
  (interactive)
  (move-beginning-of-line 1)
  (outline-show-entry)
  (move-beginning-of-line 1)
  (delete-forward-char 1)
  (move-end-of-line 1)
  (delete-backward-char 1)
  (move-beginning-of-line 1)
  (outline-hide-entry))

(what-line)
(insert)
(map!
     :map dokuwiki-mode-map
     "<backtab>"    #'outline-cycle-buffer
     "<tab>"        #'outline-cycle
;;     "C-c C-p C-d"  #'clever-math
     "M-<right>"    #'dokuwiki-demote
     "M-<left>"     #'dokuwiki-promote
     "C-c C-o"       'my-find-link
     "C-<return>" #'dokuwiki-insert-heading
     "C-c C-l"      #'my/insert-link)
