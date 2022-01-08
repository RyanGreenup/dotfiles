;;; init-evil.el --- Load the Evil Layer and Leader  keys   ---
;;; Commentary:
;;; Code:



;; Enable Evil
(setq evil-want-C-u-scroll t)
(evil-mode)

;; Leader Keys
(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'insert (kbd "M-["))
(evil-set-leader 'visual (kbd "M-SPC"))
(evil-set-leader 'replace (kbd "M-SPC"))
(evil-define-key 'normal 'global (kbd "<leader>oF") 'make-frame)
(evil-define-key 'normal 'global (kbd "<leader>ot") '(find-file "~/Notes/Org/agenda/todo.org"))
(evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)
(evil-define-key 'normal 'global (kbd "<leader>fz") 'fzf) 
(evil-define-key 'normal 'global (kbd "<leader>wv") 'evil-window-vsplit)
(evil-define-key 'normal 'global (kbd "<leader>ws") 'evil-window-split)
(evil-define-key 'normal 'global (kbd "<leader>wd") 'evil-quit)
(evil-define-key 'normal 'global (kbd "<leader>wl") 'evil-window-right)
(evil-define-key 'normal 'global (kbd "<leader>wh") 'evil-window-left)
(evil-define-key 'normal 'global (kbd "<leader>wj") 'evil-window-down)
(evil-define-key 'normal 'global (kbd "<leader>wk") 'evil-window-up)
(evil-define-key 'normal 'global (kbd "<leader>wL") 'evil-window-move-far-right)
(evil-define-key 'normal 'global (kbd "<leader>wH") 'evil-window-move-far-left)
(evil-define-key 'normal 'global (kbd "<leader>wJ") 'evil-window-move-far-down)
(evil-define-key 'normal 'global (kbd "<leader>wK") 'evil-window-move-far-up)
(evil-define-key 'normal 'global (kbd "<leader>wo") 'doom/window-enlargen)
(evil-define-key 'normal 'global (kbd "<leader>bp") 'previous-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bn") 'next-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bd") 'kill-buffer)
(evil-define-key 'normal 'global (kbd "<leader>bD") 'kill-buffer-and-window)
(evil-define-key 'normal 'global (kbd "<leader>fy") 'My-Copy-File-Path)
;; (evil-define-key 'normal 'global (kbd "<leader>ff") 'find-file) ; Use helm
(evil-define-key 'normal 'global (kbd "<leader>ht") 'load-theme) ;; see also counsel-load-theme in init-ivy
(evil-define-key 'normal 'global (kbd "<leader>hrt") 'reset-theme)
(evil-define-key 'normal 'global (kbd "<leader>fr") 'consult-recent-file)
(evil-define-key 'normal 'global (kbd "<leader>fp") 'open-local-config)
(setq vc-follow-symlinks t) ;; Must follow for version control to work
(evil-define-key 'normal 'global (kbd "<leader>SPC") 'projectile--find-file)
(evil-define-key 'normal 'global (kbd "<leader>gs") 'git-gutter:stage-hunk)
(evil-define-key 'normal 'global (kbd "<leader>gS") 'magit-stage-file)
(evil-define-key 'normal 'global (kbd "<leader>gc") 'magit-commit)
(evil-define-key 'normal 'global (kbd "<leader>gt") 'git-timemachine)
(evil-define-key 'normal 'global (kbd "<leader>bb") 'helm-buffers-list)
(evil-define-key 'normal 'global (kbd "<leader>nb") 'rg-for-backlinks)
(evil-define-key 'normal 'global (kbd "<leader>nb") 'org-cliplink)
(evil-define-key 'normal 'global (kbd "<leader>nrf") 'org-roam-node-find)
(evil-define-key 'normal 'global (kbd "<leader>nri") 'org-roam-node-insert)
(evil-define-key 'normal 'global (kbd "<leader>nru") 'my/roam/org-id-update-id-current-file)
(evil-define-key 'normal 'global (kbd "<leader>'") 'helm-resume)
(evil-define-key 'normal 'global (kbd "<leader>'") 'helm-resume)
(evil-define-key 'normal 'global (kbd "<leader>wu") 'winner-undo)
(evil-define-key 'normal 'global (kbd "<leader>wU") 'winner-redo)
(evil-define-key 'normal 'global (kbd "<leader>zns") 'org-narrow-to-subtree)
(evil-define-key 'normal 'global (kbd "<leader>znb") 'org-narrow-to-block)
(evil-define-key 'normal 'global (kbd "<leader>zne") 'org-narrow-to-element)
(evil-define-key 'normal 'global (kbd "<leader>znp") 'narrow-to-page)
(evil-define-key 'normal 'global (kbd "<leader>znd") 'narrow-to-defun)
(evil-define-key 'normal 'global (kbd "<leader>znn") 'narrow-to-region)
(evil-define-key 'normal 'global (kbd "<leader>znw") 'widen)
(evil-define-key 'normal 'global (kbd "<leader>.a") 'hydra-org-agenda/body)
(evil-define-key 'normal 'global (kbd "<leader>.c") 'hydra-clock-menu/body)
(evil-define-key 'normal 'global (kbd "<leader>.w") 'hydra-window-menu/body)
(evil-define-key 'normal 'global (kbd "<leader>wo") 'doom/window-enlargen)
(evil-define-key 'normal 'global (kbd "<leader>w=") 'balance-windows)
(evil-define-key 'normal 'global (kbd "<leader>`") 'pop-vterm)
(evil-define-key 'normal 'global (kbd "<leader>x") 'pop-scratch)
(evil-define-key 'normal 'global (kbd "<leader>X") 'org-capture)
(evil-define-key 'normal 'global (kbd "<leader>q") 'popwin:close-popup-window)
(evil-define-key 'normal 'global (kbd "zn") 'doom/toggle-narrow-buffer)
(evil-define-key 'normal 'global (kbd "<leader>/") 'helm-rg)
(evil-define-key 'normal 'global (kbd "<leader>iu") 'helm-unicode)
(evil-define-key 'normal 'global (kbd "<leader>rhh") 'helm-org-in-buffer-headings)
(evil-define-key 'normal 'global (kbd "<leader>rha") 'helm-org-agenda-files-headings)


;; Evil Jump
(evil-define-key 'normal 'global (kbd "gss") 'avy-goto-char-2)
(evil-define-key 'normal 'global (kbd "gsS") 'avy-goto-word-1)

;;; Evil Escape
(setq-default evil-escape-key-sequence (kbd "jk"))
(setq-default evil-escape-delay 0.3)

;;; Org Ref
(evil-define-key 'normal 'global (kbd "<leader>lrl") 'org-ref-insert-ref-link)
(evil-define-key 'normal 'global (kbd "<leader>lrc") 'org-ref-helm-insert-cite-link)
 
;;; helm-org-rifle
(evil-define-key 'normal 'global (kbd "<leader>hh") 'helm-org-in-buffer-headings)
(evil-define-key 'normal 'global (kbd "<leader>ha") 'helm-org-agenda-files-headings)
(evil-define-key 'normal 'global (kbd "<leader>rb") 'helm-org-rifle-current-buffer)
(evil-define-key 'normal 'global (kbd "<leader>ro") 'helm-org-rifle-org-directory)
(evil-define-key 'normal 'global (kbd "<leader>rd") 'helm-org-rifle-directories)





;;; Toggles
(evil-define-key 'normal 'global (kbd "<leader>tg") 'golden-ratio-mode)
;; (evil-define-key 'normal 'global (kbd "<leader>tl") 'global-display-line-numbers-mode)
(evil-define-key 'normal 'global (kbd "<leader>tl") 'doom/toggle-line-numbers)
(evil-define-key 'normal 'global (kbd "<leader>th") 'helm-mode)
(evil-define-key 'normal 'global (kbd "<leader>t SPC") 'menu-bar-mode)
(evil-define-key 'normal 'global (kbd "<leader>tb") 'org-supertar-mode)
(evil-define-key 'normal 'global (kbd "<leader>ti") 'highlight-indent-guides-mode)
(evil-define-key 'normal 'global (kbd "<leader>tz") 'writeroom-mode)
(evil-define-key 'normal 'global (kbd "<leader>tr") 'display-fill-column-indicator-mode)
(setq highlight-indent-guides-method 'character)


(defun reset-theme ()
  "Unload the theme"
  (interactive)
  (save-window-excursion
    (eval (mapc 'disable-theme custom-enabled-themes) t)
    )
  )


(defun open-local-config ()
  (interactive)
  (find-file "~/.config/emacs/init.el")
  )

(defun My-Copy-File-Path ()
  (interactive)
  (save-window-excursion
(kill-new
            (shell-quote-argument buffer-file-name))

(message
            (shell-quote-argument buffer-file-name))
))


;; KBD
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
(set 'org-return-follows-link t)

;;; Doom Functions

;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(defun doom-resize-window (window new-size &optional horizontal force-p)
  "Resize a window to NEW-SIZE. If HORIZONTAL, do it width-wise.
If FORCE-P is omitted when `window-size-fixed' is non-nil, resizing will fail."
  (with-selected-window (or window (selected-window))
    (let ((window-size-fixed (unless force-p window-size-fixed)))
      (enlarge-window (- new-size (if horizontal (window-width) (window-height)))
                      horizontal))))



(defun doom/toggle-line-numbers ()
  "Toggle line numbers.
Cycles through regular, relative and no line numbers. The order depends on what
`display-line-numbers-type' is set to. If you're using Emacs 26+, and
visual-line-mode is on, this skips relative and uses visual instead.
See `display-line-numbers' for what these values mean."
  (interactive)
  ;; First Enable Line Numbers if not enabled already ;; Ryan G. 2020-01-30
(if global-display-line-numbers-mode nil
    (global-display-line-numbers-mode)
  )
  (defvar doom--line-number-style display-line-numbers-type)
  (let* ((styles `(t ,(if visual-line-mode 'visual 'relative) nil))
         (order (cons display-line-numbers-type (remq display-line-numbers-type styles)))
         (queue (memq doom--line-number-style order))
         (next (if (= (length queue) 1)
                   (car order)
                 (car (cdr queue)))))
    (setq doom--line-number-style next)
    (setq display-line-numbers next)
    (message "Switched to %s line numbers"
             (pcase next
               (`t "normal")
               (`nil "disabled")
               (_ (symbol-name next))))))



(defun doom/window-enlargen (&optional arg)
  "Enlargen the current window to focus on this one. Does not close other
windows (unlike `doom/window-maximize-buffer'). Activate again to undo."
  (interactive "P")
  (let* ((window (selected-window))
         (dedicated-p (window-dedicated-p window))
         (preserved-p (window-parameter window 'window-preserved-size))
         (ignore-window-parameters t)
         (window-resize-pixelwise nil)
         (frame-resize-pixelwise nil))
    (unwind-protect
        (progn
          (when dedicated-p
            (set-window-dedicated-p window nil))
          (when preserved-p
            (set-window-parameter window 'window-preserved-size nil))
          (maximize-window window))
      (set-window-dedicated-p window dedicated-p)
      (when preserved-p
        (set-window-parameter window 'window-preserved-size preserved-p)))))


;;;###autoload
(defun doom/window-maximize-horizontally ()
  "Delete all windows to the left and right of the current window."
  (interactive)
  (require 'windmove)
  (save-excursion
    (while (ignore-errors (windmove-left)) (delete-window))
    (while (ignore-errors (windmove-right)) (delete-window))))

;;;###autoload
(defun doom/window-maximize-vertically ()
  "Delete all windows above and below the current window."
  (interactive)
  (require 'windmove)
  (save-excursion
    (while (ignore-errors (windmove-up)) (delete-window))
    (while (ignore-errors (windmove-down)) (delete-window))))




(defun doom/toggle-narrow-buffer (beg end)
  "Narrow the buffer to BEG END. If narrowed, widen it."
  (interactive
   (list (or (bound-and-true-p evil-visual-beginning) (region-beginning))
         (or (bound-and-true-p evil-visual-end)       (region-end))))
  (if (buffer-narrowed-p)
      (widen)
    (unless (region-active-p)
      (setq beg (line-beginning-position)
            end (line-end-position)))
    (narrow-to-region beg end)))

(evil-define-key 'normal 'global
  (kbd "<leader>p")
  (lambda
    ()
    (interactive)
    (message "user printed ")
    (print-time-delta)
    ))


(provide 'init-evil)
;;; init-evil.el ends here
