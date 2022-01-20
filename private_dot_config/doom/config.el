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
(setq org-agenda-files (list "~/Agenda" "~/Notes/journals"))


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
(setq my/notes_dir "~/Notes/")
(setq my/journal_dir (concat my/notes_dir "journals/"))
(setq my/tasks_list (concat my/tasks_dir "todo.org"))
;; Todays journal will have the last name using rfc3339 ⊂ iso-8601
(setq todays_journal
      (format (concat my/journal_dir "%s")
              (car (last (directory-files my/journal_dir)))))
;; Set the initial buffer
(setq initial-buffer-choice todays_journal)
;;;; Agenda Files
(setq org-directory my/tasks_dir)
(setq org-agenda-files (list my/tasks_dir my/journal_dir))
;;;; Functions
;; Journal
(defun my/open_todays_journal ()
  (interactive)
  (find-file todays_journal))
;; Takks
(defun my/open_tasks ()
  (interactive)
  (find-file my/tasks_list))
;;;; Keybindings
;;;;; General Emacs
;; (global-set-key (kbd "<f1> j") 'my/open_todays_journal)
;; (global-set-key (kbd "<f1> t") 'my/open_tasks)
;;;;; Doom
(map! :leader
      :desc "Open Todays journal" "<f2> t" 'my/open_tasks)
(map! :leader
      :desc "Open Todays journal" "<f2> j" 'my/open_todays_journal)
;;; Misc Hooks etc
(setq org-logseq-dir "~/Notes")
(map! :leader
      :desc "Open Logseq Contents" "l c" #'org-logseq-toggle-contents-sidebar)
()

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
