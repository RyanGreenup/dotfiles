;;; init-elpa.el --- Settings and helpers for straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents t)


(provide 'init-elpa)
;;; init-elpa.el ends here
