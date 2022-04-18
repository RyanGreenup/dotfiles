;;; init-popup-scratch.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;; TODO Only create the popup buffer for vterm/eshell if it is needed

(defvar init-is-pop-scratch-up)
(setq init-is-pop-scratch-up nil)
(defvar init-my-scratch-file "~/Sync/Scratch")


;;; Scratch buffer
(defun pop-scratch ()
  "Pop up a scratch Buffer"
    (interactive)
    (if init-is-pop-scratch-up
        (close-popup-scratch)
        (open-popup-scratch)
    )
)

(defun open-popup-scratch ()
  (setq init-is-pop-scratch-up t)
  (find-file-noselect init-my-scratch-file)
  (popwin:popup-buffer "*scratch*")
  ;; (popwin:popup-buffer init-my-scratch-file)
  (evil-insert 1)
)

(defun close-popup-scratch ()
  (setq init-is-pop-scratch-up nil)
  (popwin:close-popup-window)
  )


(provide 'init-popup-scratch)
;;; Vterm buffer
(defvar init-is-pop-vterm-up)
(setq init-is-pop-vterm-up nil)
(defvar init-my-scratch-file "~/Sync/Scratch")

(defvar vterm-buffer-name "Pop-Vterm")


(defun pop-vterm ()
  "Pop up a vterm Buffer"
    (interactive)
    (if init-is-pop-vterm-up
        (close-popup-vterm)
        (open-popup-vterm)
    )
)



(defun open-popup-vterm ()
    (if (get-buffer vterm-buffer-name) nil
	(save-window-excursion (vterm vterm-buffer-name))
    )
  (setq init-is-pop-vterm-up t)
  (popwin:popup-buffer vterm-buffer-name)
  ;; (popwin:popup-buffer init-my-vterm-file)
  (evil-insert 1)
)

(defun close-popup-vterm ()
  (setq init-is-pop-vterm-up nil)
  (popwin:close-popup-window)
  (evil-insert 1)
  )


(provide 'init-popup-scratch)
;;; Eshell buffer
(defvar init-is-pop-eshell-up)
(setq init-is-pop-eshell-up nil)
(defvar init-my-scratch-file "~/Sync/Scratch")


(defvar eshell-buffer-name "Pop-eshell")

(defun pop-eshell ()
  "Pop up a eshell Buffer"
    (interactive)
    (if init-is-pop-eshell-up
        (close-popup-eshell)
        (open-popup-eshell)
    )
)

(defun open-popup-eshell ()
    (if (get-buffer eshell-buffer-name) nil
	(save-window-excursion (eshell eshell-buffer-name))
    )
  (popwin:popup-buffer eshell-buffer-name)
  (setq init-is-pop-eshell-up t)
  (evil-insert 1)
)

(defun close-popup-eshell ()
  (setq init-is-pop-eshell-up nil)
  (popwin:close-popup-window)
  (evil-insert 1)
  )



(provide 'init-popup-scratch)
;;; init-popup-scratch.el ends here



