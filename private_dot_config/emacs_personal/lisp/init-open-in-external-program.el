;;; init-open-in-external-program.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

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

(defun my-open-current-file-in-vim ()
  (interactive)
  (save-window-excursion
   (async-shell-command
                                        ;  (format "gvim +%d %s"
    (format "/usr/bin/kitty -e nvim +%d %s"
            (+ (if (bolp) 1 0) (count-lines 1 (point)))
            (shell-quote-argument buffer-file-name)))
   ))


(provide 'init-open-in-external-program)
;;; init-open-in-external-program.el ends here
