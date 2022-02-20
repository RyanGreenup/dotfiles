;;; lisp/init-org-ref.el -*- lexical-binding: t; -*-


(after! org
  (require 'org-ref-ivy)

  (setq org-ref-insert-link-function 'org-ref-insert-link-hydra/body
        org-ref-insert-cite-function 'org-ref-cite-insert-ivy
        org-ref-insert-label-function 'org-ref-insert-label-link
        org-ref-insert-ref-function 'org-ref-insert-ref-link
        org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body)))

  (setq bibtex-completion-bibliography '("~/Notes/ref.bib")                        ;; NOTE .bib file location
        bibtex-completion-library-path '("~/Zotero/storage/")                      ;; NOTE PDF file location (TODO need flat ./citeky.pdf files)
        bibtex-completion-notes-path "~/Notes/refs/"                            ;; NOTE lit notes .org file
        bibtex-completion-additional-search-fields '(keywords)
        bibtex-completion-pdf-open-function
          (lambda (fpath)
                  (call-process "zathura" nil 0 nil fpath)))


  (define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link))

;;; Set the org-mode latex backend
(after! org
  ; LaTeXMk is more efficient
  ;; Execute either depending on which one you want, and or swap order
  (setq org-latex-listings 'minted
    org-latex-packages-alist '(("" "minted"))
    org-latex-pdf-process
    '("latexmk -8bit -f -shell-escape -xelatex -interaction=nonstopmode %F")))

(provide 'init-org-ref)
;;; init-org-super-agenda.el ends here
