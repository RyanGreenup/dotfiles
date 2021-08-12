;;; hydra-clock.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defhydra hydra-clock-menu (
			    :pre (setq which-key-inhibit t)
                            :post (setq which-key-inhibit nil)
			    :color blue
                           :hint none)
    "
    ^
    ^Clock^             ^Do^
    ^─────^─────────────^──^─────────
    _q_ quit            _c_ cancel
    ^^                  _d_ display
    ^^                  _e_ effort
    ^^                  _i_ in
    ^^                  _j_ jump
    ^^                  _o_ out
    ^^                  _r_ report
    ^^                  ^^
    "
    ("q" nil)
    ("c" org-clock-cancel :color pink)
    ("d" org-clock-display)
    ("e" org-clock-modify-effort-estimate)
    ("i" org-clock-in)
    ("j" org-clock-goto)
    ("o" org-clock-out)
    ("r" org-clock-report))



(provide 'hydra-clock)
;;; hydra-clock.el ends here
