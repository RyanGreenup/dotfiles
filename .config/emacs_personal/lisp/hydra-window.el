;;; hydra-window.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defhydra hydra-window-menu ()
  "
    Travel^  Movement^   ^Split^         ^Switch^       ^^^Resize^         ^Window Purpose^
    ---------- ------------------------------------------------------------------------------------------------------
    _h_ ←      _H_ ←        _|_ vertical    ^_b_uffer       _M-h_  X←     choose window _P_urpose
    _j_ ↓      _J_ ↓        _-_ horizontal  ^_f_ind files   _M-j_  X↓     switch to _B_uffer w/ same purpose
    _k_ ↑      _K_ ↑        _u_ undo        ^_a_ce window   _M-k_    X↑     Purpose-dedication(_!_)
    _l_ →      _L_ →        _r_ reset       ^_s_wap         _M-l_ X→     Buffer-dedication(_#_)
    ^^^^^^^                                      _M_aximize
    ^^^^^^^                                      _d_elete
    _x_ M-x      _q_ quit
    "
  ("h" windmove-left)
  ("j" windmove-down)
  ("k" windmove-up)
  ("l" windmove-right)
  ("H" evil-window-move-far-left)
  ("J" evil-window-move-far-down)
  ("K" evil-window-move-far-up)
  ("L" evil-window-move-far-right)
  ("|" (lambda ()
         (interactive)
         (split-window-right)
         (windmove-right)))
  ("-" (lambda ()
         (interactive)
         (split-window-below)
         (windmove-down)))
  ("u" (progn
         (winner-undo)
         (setq this-command 'winner-undo)))
  ("r" winner-redo)
  ("b" helm-source-buffers-list)
  ("f" helm-find)
  ("a" (lambda ()
         (interactive)
         (ace-window 1)
         (add-hook 'ace-window-end-once-hook
                   'hydra-window/body)))
  ("s" (lambda ()
         (interactive)
         (ace-swap-window)
         (add-hook 'ace-window-end-once-hook
                   'hydra-window/body)))
  ("M-h" (shrink-window-horizontally 15))
  ("M-j" (shrink-window 10))
  ("M-k" (enlarge-window 15))
  ("M-l" (enlarge-window-horizontally 15))
  ("M" delete-other-windows)
  ("d" delete-window)

  ("P" purpose-set-window-purpose)
  ("B" ivy-purpose-switch-buffer-with-purpose)
  ("!" purpose-toggle-window-purpose-dedicated)
  ("#" purpose-toggle-window-buffer-dedicated)

  ;; ("K" ace-delete-other-windows)
  ;; ("S" save-buffer)
  ;; ("d" delete-window)
  ;; ("D" (lambda ()
  ;;        (interactive)
  ;;        (ace-delete-window)
  ;;        (add-hook 'ace-window-end-once-hook
  ;;                  'hydra-window/body))
  ;;  )

  ("x" counsel-M-x)
  ("q" nil)
  )
(global-set-key (kbd "<f1>") 'hydra-window-menu/body)


(provide 'hydra-window)
;;; hydra-window.el ends here
