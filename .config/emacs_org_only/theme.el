(setq dark-theme 'leuven-dark)
(setq light-theme 'leuven)
(defun switch-theme-according-to-time ()
  "Switch to 'leuven' theme between 6AM - 6PM, and 'leuven-dark' theme between 6PM - 6AM."
  (interactive)
  (let ((hour (nth 2 (decode-time (current-time)))))
    (if (member hour (number-sequence 6 17))
        (progn
          (disable-theme dark-theme)
          (load-theme light-theme t))
      (progn
        (disable-theme light-theme)
        (load-theme dark-theme t)))))

(switch-theme-according-to-time)

