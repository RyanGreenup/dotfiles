;; init-org.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; General
;;;;; User Info

(setq user-full-name "Ryan Greenup"
      user-mail-address "17805315@student.westernsydney.edu.au")
(setq org-startup-folded "overview")
(setq org-agenda-span 10
    org-agenda-start-on-weekday nil
    org-agenda-start-day "-3d")
(setq org-cycle-include-plain-lists 'integrate)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-use-tag-inheritance t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-tags-column 80)
(setq org-agenda-files '("~/Agenda/"))

;; Hide Finished Agenda Items
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)
;;;;; Org Capture
(setq org-capture-templates
      '(("t" "Task" entry (file+headline "~/Agenda/todo.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/Agenda/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))
;;;;; Spell Check
(add-to-list 'ispell-skip-region-alist '("#\\+begin_src". "#\\+end_src"))
;;;;; Appearance
(setq org-display-inline-images t)
(setq org-redisplay-inline-images t)
(setq org-startup-with-inline-images "inlineimages")
(setq org-hide-emphasis-markers t)
(setq org-confirm-elisp-link-function nil)
;; Open in new frame
(setq org-link-frame-setup '((file . find-file-other-window))) ;; I like having extra frames, just cill them with C-w o.

;;;;; Org Download
(setq org-download-method 'directory)
(setq-default org-download-image-dir "./media/")
;;;;; Refiling
(setq org-refile-targets '((nil :maxlevel . 9)
                                (org-agenda-files :maxlevel . 9)))
(setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
(setq org-refile-use-outline-path t)                  ; Show full paths for refiling

;;; Keybindings
;;;; Agenda
;; Move up and Down in Agenda
;; In the agenda evil doesn't work, because there are already other
;; keybindings like F for follow mode, map j/k as a compromise
(add-hook 'org-agenda-mode-hook (lambda ()
(define-key org-agenda-mode-map "j" 'evil-next-line)
(define-key org-agenda-mode-map "k" 'evil-previous-line)
(define-key org-agenda-mode-map (kbd "M-SPC" ) 'hydra-org-agenda/body)
))



;;;  Styling
    (with-eval-after-load 'org
    (setq org-hidden-keywords '(title))
;; set basic title font
    (set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
    )
;; Resize Images
(setq org-image-actual-width nil)

;;; Periodically When Idle
;; Maybe Rebuild Org-Agenda?

;;; Exports
;;;; LaTeX
;;;;; Captions go Below Table
(setq org-latex-caption-above nil)

;;;;; LaTeX Call
;(setq org-latex-listings 'listings
;      org-latex-packages-alist '(("" "listings"))
;      org-latex-pdf-process
;      '("xelatex -shell-escape -synctex=1 -interaction nonstopmode -output-directory %o %f"
;        "biber %b.bcf"
;        "xelatex -shell-escape -synctex=1 -interaction nonstopmode -output-directory %o %f"))

; (setq org-latex-listings 'minted
;       org-latex-packages-alist '(("" "minted"))
;       org-latex-pdf-process
;       '("xelatex -shell-escape -synctex=1 -interaction nonstopmode -output-directory %o %f"
;         "biber %b.bcf"
;         "xelatex -shell-escape -synctex=1 -interaction nonstopmode -output-directory %o %f"))

; LaTeXMk is more efficient
;; Execute either depending on which one you want, and or swap order
(setq org-latex-listings 'minted
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("latexmk -8bit -f -shell-escape -xelatex -interaction=nonstopmode %F")
        )

;; (setq org-latex-listings 'listings
;;       org-latex-packages-alist '(("" "listings"))
;;       org-latex-pdf-process
;;       '("latexmk -f -shell-escape -xelatex -interaction=nonstopmode %F")
;;         )

; Press f5 to Export Macro (NOTE: Use el:macro)
(fset 'Async\ Export\ Latex
   (kmacro-lambda-form [?\C-c ?\C-e ?\C-a ?l ?p] 0 "%d"))
(global-set-key [f5] 'Async\ Export\ Latex)

;;;; Preview Tikz inside Org-Mode
;; You'll need to use this with texfrag-mode
;; It doesn't seem to work with org-latex-preview-fragment
;; but texfrag mode is better anyway.
(add-to-list 'org-latex-packages-alist
             '("" "tikz" t))
(eval-after-load "preview"
  '(add-to-list 'preview-default-preamble "\\PreviewEnvironment{tikzpicture}" t))
;;;; ODT Export uses MathML
(setq org-latex-to-mathml-convert-command
      "latexmlmath \"%i\" --presentationmathml=%o")
;;;; Pandoc Org-Mode HTML Export
;; TODO offer CSS Choices
;; TODO Have the file type read automatically?
;; TODO MathJax could be put in more elegantly, maybe use a variable
;; TODO Shouldn't check for the file name four times in a row.

(defun export-org-as-self-contained-html-pandoc ()
 (interactive)
  (save-window-excursion
   (async-shell-command
    (format "pandoc %s.org --self-contained -s -B ~/.doom.d/mathjax.js -o %s.html"
     (shell-quote-argument (file-name-sans-extension buffer-file-name))
     (shell-quote-argument (file-name-sans-extension buffer-file-name))
   )
  )
 )
)

;;;; Inline Style Sheet
;; Add CSS (Be mindful that you may want to implement this in a more sensible way, similar to how beorg does it
;; Put your css files there
(defvar org-theme-css-dir "~/Templates/CSS/Org-CSS/")

(defun toggle-org-custom-inline-style ()
 (interactive)
 (let ((hook 'org-export-before-parsing-hook)
       (fun 'set-org-html-style))
   (if (memq fun (eval hook))
       (progn
         (remove-hook hook fun 'buffer-local)
         (message "Removed %s from %s" (symbol-name fun) (symbol-name hook)))
     (add-hook hook fun nil 'buffer-local)
     (message "Added %s to %s" (symbol-name fun) (symbol-name hook)))))

; Enable Css hook by default
;; I think this is better as opt in
;; Also I still need to set up the image embedding part, which I have been
;working on in visual analytics I just haven't made a nice function.
;; (add-hook 'org-mode-hook 'toggle-org-custom-inline-style)

(defun org-theme ()
  (interactive)
  (let* ((cssdir org-theme-css-dir)
         (css-choices (directory-files cssdir nil ".css$"))
         (css (completing-read "theme: " css-choices nil t)))
    (concat cssdir css)))
(defun set-org-html-style (&optional backend)
 (interactive)
 (when (or (null backend) (eq backend 'html))
(let ((f (or (and (boundp 'org-theme-css) org-theme-css) (org-theme))))
     (if (file-exists-p f)
         (progn
           (set (make-local-variable 'org-theme-css) f)
           (set (make-local-variable 'org-html-head)
                (with-temp-buffer
                  (insert "<style type=\"text/css\">\n<!-- [CDATA] -->\n")
                  (insert-file-contents f)
                  (goto-char (point-max))
                  (insert "\n/;]]>;/-->\n</style>\n")
                  (buffer-string)))
           (set (make-local-variable 'org-html-head-include-default-style)
                nil)
           (message "Set custom style from %s" f))
       (message "Custom header file %s doesnt exist")))))

;;;; Email
(defun export-email ()
  (interactive)
  (message "Beginning Email Export")
  (yank-visible-org-buffer)
  (call-eml)
)
  (defun yank-visible-org-buffer ()
    (interactive)
    (goto-char (point-min))
    (mark-page)
    ;; (evil-yank (point-min) (point-max))
    (org-copy-visible (point-min) (point-max))
  )

  (defun call-eml ()
    (async-shell-command (format "~/bin/eml -o"))
  )

;;; org-ref
;; (require 'org-ref) ;; Must be required, see README
(setq reftex-default-bibliography '("~/Notes/ref.bib"))

;; see org-ref for use of these variables
(setq org-ref-bibliography-notes "~/Sync/Studies/Papers/notes.org"
      org-ref-default-bibliography '("~/Notes/ref.bib")
      org-ref-pdf-directory "~/Sync/Studies/Papers/PDFS")
;;;;; Hide Citation Syntax
(add-hook 'org-mode-hook
  (lambda ()
    (add-to-list 'font-lock-extra-managed-props 'display)
    (font-lock-add-keywords nil
     '((" \\(cite:[a-z0-9A-Z]\+\\)" 1 '(face nil display "🤔"))))

    (add-to-list 'font-lock-extra-managed-props 'display)
    (font-lock-add-keywords nil
     '((" \\(\\[\\[cite:[a-z0-9A-Z]\+\\]\\[\.\*\\]\\]\\)" 1 '(face nil display "¹"))))

  )
)
;;; Org-Roam
(defun my/org-id-update-org-roam-files ()
  "Update Org-ID locations for all Org-roam files."
  (interactive)
  (org-id-update-id-locations (org-roam--list-all-files)))
(defun my/roam/org-id-update-id-current-file ()
  "Scan the current buffer for Org-ID locations and update them."
  (interactive)
  (org-id-update-id-locations (list (buffer-file-name (current-buffer)))))
;;; Org Roam Server
(setq
        ;; org-roam-server-host "127.0.0.1"
        org-roam-server-host "0.0.0.0"
        org-roam-server-port 8080
        org-roam-server-authenticate nil
        org-roam-server-export-inline-images t
        org-roam-server-serve-files nil
        org-roam-server-served-file-extensions '("pdf" "mp4" "ogv")
        org-roam-server-network-poll t
        org-roam-server-network-arrows nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-length 60
        org-roam-server-network-label-wrap-length 20)
;;; Misc Tools
;;;; Open all org-agenda files
(defun open-all-org-agenda-files () (interactive) (let ((files (org-agenda-files))) (mapcar (lambda (x) (find-file x)) files)))
;;;; Find backlinks with counsel-rg
(defun rg-for-backlinks ()
    (interactive)
    (counsel-rg
	(file-name-nondirectory
	    (buffer-file-name)) "~/Notes"))
;;;; TODO Insert backlinks using py script
;; TODO this is (eventually) going to be rewritten in go (or rust :shrug:)
;; NOTE if you can't find it, grep for 1637991050
(defun insert-backlinks ()
     (interactive)
    (insert
    (shell-command-to-string
	(concat "python " "/home/ryan/Studies/programming/go/bleve/backlinks/backlinks.py "
		(buffer-file-name)))))
;;; Hooks
(add-hook 'org-mode-hook (lambda ()
			   (org-superstar-mode 1)
             		   (texfrag-mode 1)
			   (auto-fill-mode 1)
			   (flyspell-mode 1)
			   ))
;;;;; Prettify Buffer
(add-hook 'org-mode-hook (lambda ()
   "Beautify Org Checkbox Symbol"
   ;; (push '("[ ]" .  "☐") prettify-symbols-alist)
   ;; (push '("[X]" . "☑" ) prettify-symbols-alist)
   ;; (push '("[-]" . "❍" ) prettify-symbols-alist)
   (push '("#+begin_src" . "✨" ) prettify-symbols-alist)
   (push '("#+BEGIN_SRC" . "✨" ) prettify-symbols-alist)
   (push '("#+end_src" .   "✨" ) prettify-symbols-alist)
   (push '("#+END_SRC" .   "✨" ) prettify-symbols-alist)
   (push '("#+begin_quote" . "➲" ) prettify-symbols-alist)
   (push '("#+BEGIN_QUOTE" . "➲ " ) prettify-symbols-alist)
   (push '("#+end_quote" .   "➲" ) prettify-symbols-alist)
   (push '("#+END_QUOTE" .   "➲" ) prettify-symbols-alist)
   (push '("#+begin_comment" . "✀ " ) prettify-symbols-alist)
   (push '("#+BEGIN_COMMENT" . "✀" ) prettify-symbols-alist)
   (push '("#+end_comment" .   "✀") prettify-symbols-alist)
   (push '("#+END_COMMENT" .   "✀") prettify-symbols-alist)
   (push '("#+attr_html: :width" .   "?⇔🌍") prettify-symbols-alist)
   (push '("#+attr_html: :width" .   "?⇔🌍") prettify-symbols-alist)
   (push '("#+attr_latex: :width" .   "🖺") prettify-symbols-alist)
   (push '("#+ATTR_LATEX: :width" .   "🖺") prettify-symbols-alist)
   (push '("#+caption:" .   "✎") prettify-symbols-alist)
   (push '("#+CAPTION:" .   "✎") prettify-symbols-alist)
   (push '("#+caption:" .   "✎") prettify-symbols-alist)
   (push '("#+NAME:" .   "㋿") prettify-symbols-alist)
   (push '("#+name:" .   "㋿") prettify-symbols-alist)
   ;; (push '("DONE" .   "✅") prettify-symbols-alist)
   ;; (push '("TODO" .   "❢") prettify-symbols-alist)
   ;; (push '("STRT" .   "☯") prettify-symbols-alist)
   (push '("#+begin_src python" .   "🐍") prettify-symbols-alist)
   (push '("#+begin_src julia"  .   "🝆") prettify-symbols-alist)
   (push '("#+begin_src R"      .   "𝓡") prettify-symbols-alist)
   (push '("#+BEGIN_SRC python" .   "🐍") prettify-symbols-alist)
   (push '("#+BEGIN_SRC julia"  .   "🝆") prettify-symbols-alist)
   (push '("#+BEGIN_SRC R"      .   "𝓡") prettify-symbols-alist)
   (push '("#+BEGIN_SRC bash"      .   "💻") prettify-symbols-alist)
   (push '("#+begin_src bash"      .   "💻") prettify-symbols-alist)
   (push '("eqref:"      .   "⅀") prettify-symbols-alist)
   (prettify-symbols-mode)))

;;; After loading org
;; Seemingly this can only be done when using Doom with (after!...)
;; I should look at how that was done and review my doom config
;;;; Beginning
(add-hook 'org-mode-hook  #'after-org)
(defun after-org ()
"A function that will run once after org mode is started.
This function is called by an after 'org-mode' hook and
removes that hook after running.

The idea is to delay an action until after 'org-mode' has been
started, in order to reduce startup times.

Ideally this function should also be run after an idle timer as well."
    (message "started evaluating after-org-functions")
    (remove-hook 'org-mode-hook  #'after-org)  ;; Remove hook so it only runs once
    ;; Things to evaluate after org go here↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓



;;;;; Load Misc Packages
    (require 'init-org-super-agenda)
    (require 'init-org-publish)
    (require 'init-texfrag)
    (require 'org-ref)  ;; Org-Ref MUST be required, see README
    (setq org-roam-v2-ack t)
    (setq org-id-link-to-org-use-id t) ;; Use ids for links everywhere
    (org-roam-mode 1)

;;;;; Use Zathura for Preview
(add-to-list 'org-file-apps '("\\.pdf" . "zathura %s"))
;;;;; Active Babel languagevs
    (org-babel-do-load-languages
	    'org-babel-load-languages
	    '(  (R           . t)
		(latex       . t)
		(C           . t)
		(python      . t)
		;; (julia       . t)
		;; (mongo       . t) ;; TODO Should I set this up?
		(sqlite      . t)
		(plantuml    . t)
		(dot         . t)
		(gnuplot     . t)
		(java        . t)
		(go          . t)
		;; (javascript  . t) ;; TODO
		(sed         . t)
		(shell       . t)
		;; (mathematica . t)
		(emacs-lisp  . t)))
;;;;;; Don't Ask
    (setq org-confirm-babel-evaluate nil)
    ;; (load "~/.emacs.d/straight/repos/org/contrib/lisp/ob-julia.el") ;; HACK symlinked to straight/org/build
;;;;;; Set up Plant UML
    (setq org-plantuml-jar-path (expand-file-name "/bin/plantuml.jar"))
    (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))











      (message "Finished Loading after-org functions")
 )
;;;; Ended


;;; init-org.el ends here
(provide 'init-org)
