;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; (setq explicit-shell-file-name "/bin/bash")
(setq explicit-shell-file-name "/bin/zsh")
(defvar load_eafQ nil)
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ryan Greenup"
      user-mail-address "Ryan.Greenup@protonmail.com")

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
(setq doom-font (font-spec :family "Fira Code" :size 24))
(setq doom-variable-pitch-font (font-spec :family "Liberation Serif" :size 24))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Notes/Org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;;; Org Mode Settings
;;;; Hooks
;;;;; Pretty Fonts
(add-hook 'org-mode-hook (lambda ()
   "Beautify Org Checkbox Symbol"
   (push '("[ ]" .  "☐") prettify-symbols-alist)
   (push '("[X]" . "☑" ) prettify-symbols-alist)
   (push '("[-]" . "❍" ) prettify-symbols-alist)
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
   (push '("DONE" .   "✅") prettify-symbols-alist)
   (push '("TODO" .   "❢") prettify-symbols-alist)
   (push '("STRT" .   "☯") prettify-symbols-alist)
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

;;;;; Enable org Superstar Mode
(add-hook 'org-mode-hook
          (lambda ()
            (org-superstar-mode 1)))
;;;; After Org
(after! org
;;;;; Initial Visibility
(setq org-startup-folded "overview")
;;;;; Org-Download
(setq org-download-method 'directory)
(setq-default org-download-image-dir "./media/")
;;;; PDF Viewer (To view PDF files inside Emacs)
    ;; load pdfview
     (eval-after-load 'org '(require 'org-pdfview))
     ;; Use pdfview in org-mode
 (add-to-list 'org-file-apps '("\\.pdf\\'" . (lambda (file link) (org-pdfview-open link))))
;;;; org-ref
(setq reftex-default-bibliography '("~/Sync/Studies/Papers/references.bib"))

;; see org-ref for use of these variables
(setq org-ref-bibliography-notes "~/Sync/Studies/Papers/notes.org"
      org-ref-default-bibliography '("~/Sync/Studies/Papers/references.bib")
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
;; File Links
 (setq org-link-abbrev-alist
       '(("bugzilla"  . "http://10.1.2.9/bugzilla/show_bug.cgi?id=")
         ("url-to-ja" . "http://translate.google.fr/translate?sl=en&tl=ja&u=%h")
         ("google"    . "http://www.google.com/search?q=")
         ("gmap"      . "http://maps.google.com/maps?q=%s")
         ("vidar"     . "http://192.168.50.190/")
;;         ("DataSci"     . "~/Notes/DataSci/")  ; This isn't made relative upon HTML export
         ("omap"      . "http://nominatim.openstreetmap.org/search?q=%s&polygon=1")
         ("ads"       .
          "https://ui.adsabs.harvard.edu/search/q=%20author%3A\"%s\"")))

;;;; Org-Publish
;; Each call of setq org-publish overwrites the last
;; You must have one big list
;; Refer to    [[file:~/Notes/Org/VisualAnalytics.org::*Publishing Pathway][Publishing Pathway]]

;; (remove-hook 'org-mode-hook 'toggle-org-custom-inline-style)
;; (toggle-org-custom-inline-style)
;;;;; Github Autumn Files
;; Often times the export fails due to broken links
;; this setting prevents that
;; with org-roam sometimes the links are not even broken!
(setq org-export-with-broken-links t)

(setq org-publish-project-alist
      '(
;; (https://orgmode.org/worg/org-tutorials/org-publish-html-tutorial.html)
        ("Aut_orgfiles"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-html-publish-to-html
         :exclude ".*" ;; Regexp
         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
                   "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Aut_images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-publish-attachment)

        ("Aut_other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-publish-attachment)

        ("Autumn" :components ("Aut_orgfiles" "Aut_images" "Aut_other"))

;;;;; Server Autumn Files

        ("Server_Org"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :index-filename "index.org"
         :auto-index t
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :publishing-directory "/srv/http/Org"
         :publishing-function org-html-publish-to-html
         :exclude "*jour.*" ;; Regexp
;;         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
 ;;                  "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Server_Images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Server_Other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Server" :components ("Server_Org" "Server_Images" "Server_Other"))


;;;;; Local HTML Files

        ("Export_Org"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :index-filename "index.org"
         :auto-index t
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-html-publish-to-html
;;         :exclude "*jour.*" ;; Regexp
;;         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
 ;;                  "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Export_Images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-publish-attachment)

        ("Export_Other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-publish-attachment)

        ("Export" :components ("Export_Org" "Export_Images" "Export_Other"))


        ))
;; todo, but be mindful to move apache from root
;; Ox-Hugo
;; If you do want to split an org-file up into multiple pieces look at these:
;; [[https://lists.gnu.org/archive/html/emacs-orgmode/2015-08/msg01283.html]]
;; [[https://github.com/mbork/org-one-to-many]]
;; (withheval-after-load 'ox
;;                       (require 'ox-hugo))




;;;; Open all org-agenda files
(defun open-all-org-agenda-files () (interactive) (let ((files (org-agenda-files))) (mapcar (lambda (x) (find-file x)) files)))
;;;;; Hide Finished Agenda Items
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)

;;;; Offer all Tags for Autocomplete
  ;; this may break marking with Space.
(setq org-complete-tags-always-offer-all-agenda-tags nil)
(setq org-tags-column 80)
(setq org-agenda-files '("~/Notes/Org"))
;;;; Preview Tikz inside Org-Mode
;; You'll need to use this with texfrag-mode
;; It doesn't seem to work with org-latex-preview-fragment
;; but texfrag mode is better anyway.
(add-to-list 'org-latex-packages-alist
             '("" "tikz" t))
(eval-after-load "preview"
  '(add-to-list 'preview-default-preamble "\\PreviewEnvironment{tikzpicture}" t))
;;;; org-babel languages
;;;;;;; Active Babel languages
 (org-babel-do-load-languages
  'org-babel-load-languages
  '((R           . t)
    (latex       . t)
    (python      . t)
    (mongo       . t)
    (sqlite      . t)
    (plantuml    . t)
    (dot         . t)
    (gnuplot     . t)
    (asymptote   . t)
    (java        . t)
    (javascript  . t)
    (sed         . t)
    (shell       . t)
    (mathematica . t)
    (emacs-lisp  . t)))


;;;;;;; Set up Plant UML
 (setq org-plantuml-jar-path (expand-file-name "/bin/plantuml.jar"))
 (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
;;;; Org Bullets (Super Star Mode)
;;;;; LaTeX Style
;; hide #+TITLE:
(setq org-hidden-keywords '(title))
;; set basic title font
(set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
;; Low levels are unimportant => no scaling
(set-face-attribute 'org-level-7 nil  :inherit 'org-level-8)
(set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
(set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
(set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
;; Top ones get scaled the same as in LaTeX (\large, \Large, \LARGE)
(set-face-attribute 'org-level-3 nil :family "Liberation Serif" :inherit 'org-level-8 :height 1.2) ;\large
(set-face-attribute 'org-level-2 nil :family "Liberation Serif" :inherit 'org-level-8 :height 1.44) ;\Large
(set-face-attribute 'org-level-1 nil :family "Liberation Serif" :inherit 'org-level-8 :height 1.728) ;\LARGE
;; Only use the first 4 styles and do not cycle.
(setq org-cycle-level-faces nil)
(setq org-n-level-faces 4)
;; Document Title, (\huge)
(set-face-attribute 'org-document-title nil
                    :height 2.074
                    :foreground 'unspecified
                    :inherit 'org-level-8)
;(setq org-superstar-headline-bullets-list '(" ")) ;; '("🞛" "◉" "○" "▷")
(setq org-superstar-headline-bullets-list '("🞛" "◉" "○" "▷")) ;; '("🞛" "◉" "○" "▷")
; I'm hapy with the defaults
(setq org-superstar-item-bullet-alist
       '((?+ . ?•)
         (?* . ?➤)
         (?- . ?–)))
(setq org-superstar-remove-leading-stars nil) ; This removes the indent
;;;; Org Attach Directory
;;;; Export
;;;;; LaTeX
;;;;;; Captions go Below Table
(setq org-latex-caption-above nil)

;;;;;; LaTeX Call
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
      '("latexmk -f -shell-escape -xelatex -interaction=nonstopmode %F")
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


;; send region to buffer below (i.e. term) and press enter
;; bound to C-c m
(fset 'send-org-block-below
   (kmacro-lambda-form [?\C-c ?\' ?g ?g ?V ?G ?y ?\C-c ?\C-k ?\C-w ?j ?p ?\C-w ?k] 0 "%d"))
(global-set-key (kbd "C-c m") 'send-org-block-below)



; (fset 'wrap-in-tcolorbox
;    (kmacro-lambda-form [?/ ?# ?\\ ?+ ?e ?n ?d ?_ ?s ?r ?c return ?j ?x ?i ?# ?+ ?L ?A ?T ?E ?X ?: ?  ?\\ ?b ?e ?g ?i ?n ?\{ ?t ?c ?o ?l ?o ?r ?b ?o ?x ?\} return ?# ?+ ?L ?A ?T ?E ?X ?: ?  ?\\ ?e ?n ?d ?\{ ?t ?c ?o ?l ?o ?r ?b ?o ?x escape ?k ?o ?# ?+ ?L ?A ?T ?E ?X ?: ?  ?\\ ?t ?c ?b ?l ?o ?w ?e ?r escape ?k ?o escape ?p] 0 "%d"))
; (global-set-key "c-x\c-k\c-b" 'wrap-in-tcolorbox)

;;;;; ODT Export uses MathML
(setq org-latex-to-mathml-convert-command
      "latexmlmath \"%i\" --presentationmathml=%o")
;;;;; Pandoc Org-Mode HTML Export
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
     (shell-quote-argument (file-name-sans-extension buffer-file-name))
     (shell-quote-argument (file-name-sans-extension buffer-file-name))
     (shell-quote-argument (file-name-sans-extension buffer-file-name))
   )
  )
 )
)
;;;; Org Roam Server

  ; Must Disable +smartparens  ; /home/ryan/DotFiles/DoomEmacs/.doom.d/init.el
  ;  https://github.com/org-roam/org-roam-server/issues/75#issuecomment-672070399
  ;  https://github.com/org-roam/org-roam-server/issues/84
  (setq org-roam-server-host "0.0.0.0"
        org-roam-server-port 56432
        org-roam-server-authenticate nil
        org-roam-server-export-inline-images t
        org-roam-server-serve-files nil
        org-roam-server-served-file-extensions '("pdf" "mp4" "ogv")
        org-roam-server-network-poll t
        org-roam-server-network-arrows nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-length 60
        org-roam-server-network-label-wrap-length 20)


;;;;; Inline Style Sheet
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

;;;;; Email
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

;;; Closing After Org
)
;;; LaTeX Settings
;; ;; Use XeLatex
;; (setq-default TeX-engine 'xetex) ;; see also ~M-x TeX-engine-set~
;; ;; Make PDF by default
;; (setq-default TeX-PDF-mode t)
;; ;; Use Shell-Escape (https://tex.stackexchange.com/a/161303)
;; (setq LaTeX-command-style '(("" "%(PDF)%(latex) -shell-escape %S%(PDFout)")))



;; see also:    (these NEVER work though grrr!)
;; %%% Local Variables:
;; %%% TeX-command-extra-options: "-shell-escape"
;; %%% coding: utf-8
;; %%% mode: latex
;; %%% TeX-engine: xetex
;; %%% End:


;;; Programming
;;;; Outshine Mode
(use-package! outshine :load-path "~/.doom.d/local/"
;  :hook ((outline-minor-mode . outshine-mode))  ; Outshine should not always be enabled, breaks latex
  :config
  (map! :map outline-minor-mode-map
        :nm [tab] #'outshine-cycle
        :nm [backtab] #'outshine-cycle-buffer))

;; (define-key outline-minor-mode-map [tab] (lambda () (interactive) (+fold/toggle)))
;; (define-key outline-minor-mode-map [tab] (lambda () (interactive) (outshine-cycle)))
;; (define-key outline-minor-mode-map [backtab] (lambda () (interactive) (#'outshine-cycle-buffer)))
;;;;; Python specific nonsense
;;;; Julia LSP
;; This is needed for Julia LSP otherwise it crashes
;; https://github.com/non-Jedi/lsp-julia/issues/35
(setq lsp-enable-folding t)


;;; ESS Settings
;;;; Auto-Scroll Inferior Buffer
;; (setq comint-prompt-read-only t) ;; Avoid this, causes problems [[https://stackoverflow.com/a/2710510/10593632]]
(setq comint-scroll-to-bottom-on-input t) ;; does
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
;;;; Company mode Auto complete delay
(after! company (setq company-idle-delay 1))
(after! company (setq company-tooltip-idle-delay 1))

;;;; Insert R Heading





(defun Insert-R-Heading-1 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## * ")
          (insert hname)

          (insert " ")
          (insert
            (apply 'concat (make-list (- 73 hlen) "-"))
           )
       )
     )
    )
)
(defun Insert-R-Heading-2 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## ** ")
          (insert hname)
          (insert " ")
          (insert
            (apply 'concat (make-list (- 72 hlen) "="))
           )
       )
     )
    )
)
(defun Insert-R-Heading-3 ()
  (interactive)
  (outshine-mode)
  (let ((hname (read-from-minibuffer "Heading Name: ")))
    (message (number-to-string (length hname)))
    (let ((hlen (length hname)))
      (let ((num (- 80 hlen)))
        (message (number-to-string num))
          (insert "## *** ")
          (insert hname)
          (insert " ")
          (insert
            (apply 'concat (make-list (- 71 hlen) "#"))
           )
       )
     )
    )
)


;;; Keybindings
;;;; ESS
 (map!  :after ess
        :map ess-mode-map
        :localleader
        "l" #'ess-eval-region-or-function-or-paragraph
        "1" #'Insert-R-Heading-1
        "2" #'Insert-R-Heading-2
        "3" #'Insert-R-Heading-3
        "d" #'ess-eval-region-or-function-or-paragraph-and-step
 )

(defun myR/tidyverse-pipe ()
  (interactive)
  (insert " %>% "))

(defun myR/assign ()
  (interactive)
  (insert " <- "))

(add-hook 'ess-mode-hook
  (lambda ()
    (local-set-key (kbd "C-S-r") 'Insert-R-Heading-1)
    (local-set-key (kbd "C-|") 'myR/tidyverse-pipe)
    (local-unset-key (kbd "M--"))
    (local-set-key (kbd "M--") 'myR/assign)
    (outshine-mode)
  )
)
;;;; Python

(defun python-mode-send-line-and-move-down ()
  (interactive)
  (setq last-command-event 5)
  (python-shell-send-statement nil t)
  (setq last-command-event 14)
  (next-line 1 1)
  (setq last-command-event 'f4))

(defun python-mode-send-line ()
  (interactive)
  (setq last-command-event 5)
  (python-shell-send-statement nil t)
  (setq last-command-event 'f4))


(add-hook 'python-mode-hook
  (lambda ()
    (local-set-key (kbd "M-RET") 'python-mode-send-line)
    (local-set-key (kbd "C-c C-n") 'python-mode-send-line-and-move-down)
    (local-set-key (kbd "C-RET") 'python-mode-send-line-and-move-down)
    (outshine-mode)
    ;; (run-python)
  )
  )


;;;; Other

(map!  :after markdown-mode
        :map markdown-mode-map
        :localleader
        "f z" 'my-open-current-file-in-zettlr
        "f t" 'my-open-current-file-in-typora
        "f m" 'my-open-current-file-in-marktext
        "f c" 'my-open-current-file-in-vscode
 )


(map!  :after org
        :map org-mode-map
        :localleader
;;      "l r l" 'org-ref-helm-insert-ref-link
      "l r l" 'org-ref-insert-ref-link
      "l r c" 'org-ref-helm-insert-cite-link
 )


(map! :leader
;; #' delimits namespace, i.e. local var
      "h L" #'global-keycast-mode
      "f t" #'find-in-dotfiles
      "f T" #'browse-dotfiles
      "f k" #'darkroom-mode ;; Just use zen mode with SPC t z
      "i n" 'open-wiki-index
      "r o" 'helm-org-rifle-org-directory ;; [[89238]] ord-dir is different to agenda
      "f z" 'counsel-fzf
      "r b" 'helm-org-rifle-current-buffer
      "r d" 'helm-org-rifle-directories
      "o !" 'open-all-org-agenda-files
      "/"   'helm-rg
      "r hh" 'helm-org-in-buffer-headings
      "r ha" 'helm-org-agenda-files-headings
      "f mz" 'my-open-current-file-in-zettlr
      "f mt" 'my-open-current-file-in-typora
      "f mm" 'my-open-current-file-in-marktext
      "f mc" 'my-open-current-file-in-vscode
      "f y" 'My-Copy-File-Path
      )
;;;; Markdown Mode
;;;;; Open in Other programs

(defun my-open-current-file-in-zettlr ()
  (interactive)
  (save-window-excursion
   (async-shell-command
    (format "zettlr  %S"
            (shell-quote-argument buffer-file-name))))
  )

(defun my-open-current-file-in-marktext ()
  (interactive)
  (save-window-excursion
  (async-shell-command
   (format "marktext %S"
           (shell-quote-argument buffer-file-name)))))

(defun my-open-current-file-in-typora ()
  (interactive)
  (save-window-excursion
   (async-shell-command
    (format "typora %S"
            (shell-quote-argument buffer-file-name)))
   ))

(defun my-open-current-file-in-vscode ()
  (interactive)
  (save-window-excursion
   (async-shell-command

    (format "code --add ~/Notes/MD/notes --goto %S:%d"
            (shell-quote-argument buffer-file-name)
            (+ (if (bolp) 1 0) (count-lines 1 (point)))
            ))
   ))


;;;;; Copy Relative Path for file
;;;;; Open Wiki Link Under Cursor
(defun fzf-wiki-link-under-cursor ()
  (interactive)
  (setq last-command-event 118)
  (evil-visual-char nil nil 'inclusive t)
  (setq last-command-event 91)
  (evil-inner-bracket nil 2705 2706 'inclusive)
  (setq last-command-event 121)
  (evil-yank 2703 2725 'inclusive nil nil)
  (setq last-command-event 41))
;;;;; Change Key Bindings for links
(add-hook 'markdown-mode-hook
  (lambda ()
    (local-set-key (kbd "C-c C-x C-l") 'org-toggle-latex-fragment)
    (local-set-key (kbd "C-c C-x C-u") 'markdown-toggle-url-hiding)
  )
)

;;;;; Copy File Path in a way that works with realpath
(defun My-Copy-File-Path ()
  (interactive)
  (save-window-excursion
(kill-new
            (shell-quote-argument buffer-file-name))

(message
            (shell-quote-argument buffer-file-name))
))
;;;; Remap Esc
(setq evil-escape-key-sequence "jk") ;; This is better because the cursor will
                                     ;; remain stationary, no pressing kk after
                                     ;; a jj
;;;; Agenda
(global-set-key (kbd "C-c a") 'org-agenda)
;;;; Open in vim
(defun my-open-current-file-in-vim ()
  (interactive)
  (save-window-excursion
   (async-shell-command
                                        ;  (format "gvim +%d %s"
    (format "/usr/bin/kitty -e nvim +%d %s"
            (+ (if (bolp) 1 0) (count-lines 1 (point)))
            (shell-quote-argument buffer-file-name)))
   ))

;;;; Edit Math with TexMacs
;; I should probably make this take the text as STDIN not CLIPBOARD
(defun my-edit-region-with-texmacs ()
  (interactive)
  (clipboard-kill-region (region-beginning) (region-end))
  (save-window-excursion
    (async-shell-command (format "~/bin/FixMathWithTexMacs.sh"))
  )
;;  (clipboard-yank)
)

(defun my-edit-clipboard-with-texmacs ()
  (interactive)
  (save-window-excursion
    (async-shell-command (format "xclip -selection clipboard -o | figlet | xclip -selection clipboard"))
  )
)





(defun my-take-screenshot ()
    (interactive)
    (let
        ;; Read Filename from Minibuffer
        ((filename (read-from-minibuffer "image file name: "))
        (directory "media"))

        ;; Use maim to screenshot
          ;; make directory
        (shell-command (format "mkdir -p %s/%s" default-directory directory))
          ;; Screenshot
        (shell-command (format "maim --select %s/%s/%s.png" default-directory directory filename ))

        ;; Insert formatted link at point
        (save-excursion (insert(format
        "#+attr_html: :width 400px \n #+attr_latex: :width 0.4\\textwidth \n [[file:%s/%s.png]]"
        directory filename)))

        ;; Message success to the minibuffer
        (message "saved to %s as %s.png" directory filename)
    )
)

(defun my-insert-clipboard-png ()
    (interactive)
    (let
        ;; Read Filename from Minibuffer
        ((filename (read-from-minibuffer "image file name: "))
        (directory "_media"))

        ;; Use maim to screenshot
        (shell-command (format "mkdir -p %s/%s" default-directory directory))
        (shell-command (format "xclip -selection clipboard -t image/png -o > %s/%s/%s.png" default-directory directory filename ))

        ;; Insert formatted link at point
        (save-excursion (insert(format
        "#+attr_html: :width 400px \n#+attr_latex: :width 0.4\\textwidth \n[[file:%s/%s.png]]"
        directory filename)))

        ;; Message success to the minibuffer
        (message "saved to %s as %s.png" directory filename)
    )
)

(defun org-copy-src-block ()
  (interactive)
  (org-edit-special nil)
  (mark-whole-buffer)
  (kill-ring-save 38 1 1)
  (org-edit-src-abort))



;; (global-set-key (kbd "C-c M") 'my-edit-region-with-texmacs)
;; (global-set-key (kbd "C-c m") 'my-edit-clipboard-with-texmacs)
(global-set-key (kbd "C-c v") 'my-open-current-file-in-vim)
(global-set-key (kbd "C-c s") 'company-yasnippet)
;;; EAF
;; Beware this takes about 2 seconds to load so it makes things feel slow.
(if load_eafQ
        (after! org
        ;; Load EAF
        (use-package eaf
        :load-path "~/.emacs.d/site-lisp/emacs-application-framework" ; Set to "/usr/share/emacs/site-lisp/eaf" if installed from AUR
        :custom
        (eaf-find-alternate-file-in-dired t)
        :config
        (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
        (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
        (eaf-bind-key take_photo "p" eaf-camera-keybinding))
        )
)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#282c34" "#F92672" "#A6E22E" "#E6DB74" "#66D9EF" "#FD5FF0" "#A1EFE4" "#F8F8F2"])
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(compilation-message-face 'default)
 '(doom-modeline-mode t)
 '(eaf-find-alternate-file-in-dired t t)
 '(fci-rule-color "#3C3D37")
 '(highlight-changes-colors '("#FD5FF0" "#AE81FF"))
 '(highlight-tail-colors
   '(("#3C3D37" . 0)
     ("#679A01" . 20)
     ("#4BBEAE" . 30)
     ("#1DB4D0" . 50)
     ("#9A8F21" . 60)
     ("#A75B00" . 70)
     ("#F309DF" . 85)
     ("#3C3D37" . 100)))
 '(jdee-db-active-breakpoint-face-colors (cons "#1E2029" "#bd93f9"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#1E2029" "#50fa7b"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#1E2029" "#565761"))
 '(magit-diff-use-overlays nil)
 '(nrepl-message-colors
   '("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3"))
 '(objed-cursor-color "#ff5555")
 '(package-selected-packages
   '(ob-mongo elpy lsp-pyright lsp-pyre ox-reveal org-re-reveal apache-mode org-roam-server leuven-theme afternoon-theme cyberpunk-2019-theme monokai-theme zenburn-theme dracula-theme texfrag elmacro fzf ranger))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(pos-tip-background-color "#FFFACE")
 '(pos-tip-foreground-color "#272822")
 '(preview-transparent-color '(highlight :background))
 '(rustic-ansi-faces
   ["#282a36" "#ff5555" "#50fa7b" "#f1fa8c" "#61bfff" "#ff79c6" "#8be9fd" "#f8f8f2"])
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   '((20 . "#F92672")
     (40 . "#CF4F1F")
     (60 . "#C26C0F")
     (80 . "#E6DB74")
     (100 . "#AB8C00")
     (120 . "#A18F00")
     (140 . "#989200")
     (160 . "#8E9500")
     (180 . "#A6E22E")
     (200 . "#729A1E")
     (220 . "#609C3C")
     (240 . "#4E9D5B")
     (260 . "#3C9F79")
     (280 . "#A1EFE4")
     (300 . "#299BA6")
     (320 . "#2896B5")
     (340 . "#2790C3")
     (360 . "#66D9EF")))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   '(unspecified "#272822" "#3C3D37" "#F70057" "#F92672" "#86C30D" "#A6E22E" "#BEB244" "#E6DB74" "#40CAE4" "#66D9EF" "#FB35EA" "#FD5FF0" "#74DBCD" "#A1EFE4" "#F8F8F2" "#F8F8F0")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
