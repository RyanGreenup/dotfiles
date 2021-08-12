;;; init-doom-modeline --- Use a Doom Modeline  -*- lexical-binding: t -*-
;;; Commentary:
  ;; Https://github.com/domtronn/all-the-icons.el

;; DO NOT USE THIS!, it causes excruciatingly slow scrolling in org-mode
;; I don't know why, but this was the reason.


;;; Code:

(add-hook 'after-init-hook #'doom-modeline-mode)

(straight-use-package 'doom-modeline)

;;; Default Config from GitHub
;; https://github.com/domtronn/all-the-icons.el


;; How tall the mode-line should be. It's only respected in GUI.
;; If the actual char height is larger, it respects the actual height.
(setq doom-modeline-height 35)

;; How wide the mode-line bar should be. It's only respected in GUI.
(setq doom-modeline-bar-width 3)

;; The limit of the window width.
;; If `window-width' is smaller than the limit, some information won't be displayed.
(setq doom-modeline-window-width-limit fill-column)

;; Whether display the icon for `major-mode'. It respects `doom-modeline-icon'.
(setq doom-modeline-major-mode-icon t)

;; Whether display the colorful icon for `major-mode'.
;; It respects `all-the-icons-color-icons'.
(setq doom-modeline-major-mode-color-icon t)

;; Whether display the icon for the buffer state. It respects `doom-modeline-icon'.
(setq doom-modeline-buffer-state-icon t)

;; Whether display the modification icon for the buffer.
;; It respects `doom-modeline-icon' and `doom-modeline-buffer-state-icon'.
(setq doom-modeline-buffer-modification-icon t)

;; Whether to use unicode as a fallback (instead of ASCII) when not using icons.
(setq doom-modeline-unicode-fallback nil)

;; Whether display the minor modes in the mode-line.
(setq doom-modeline-minor-modes nil)

;; If non-nil, a word count will be added to the selection-info modeline segment.
(setq doom-modeline-enable-word-count t)

(provide 'init-doom-modeline)
;;; init-doom-modeline.el ends here
