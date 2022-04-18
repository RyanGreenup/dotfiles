;;; init-straight.el --- Settings and helpers for straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; Configure the modification check
;; See https://github.com/raxod502/straight.el/issues/373
;;     https://github.com/raxod502/straight.el/issues/41
;; By default straight uses find to go through for changes
;; 'live is a before-save-hook that is faster at init, if it fucks up
;; run 'straight-rebuild-package'.
(setq straight-check-for-modifications 'live)  ;; this is a before-save-hook
;;; Set up straight

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))






(provide 'init-straight)
;;; init-straight.el ends here
