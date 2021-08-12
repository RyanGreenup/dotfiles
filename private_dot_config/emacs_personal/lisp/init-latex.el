;;; init-latex.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(add-hook 'latex-mode-hook (lambda () (hs-minor-mode) (outshine-mode)))

          
(provide 'init-latex)
;;; init-latex.el ends here
