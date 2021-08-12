;;; init-org-publish.el --- All Packages for Emacs using straight.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; Org-Publish
;; Each call of setq org-publish overwrites the last
;; You must have one big list
;; Refer to    [[file:~/Notes/Org/VisualAnalytics.org::*Publishing Pathway][Publishing Pathway]]

;; (remove-hook 'org-mode-hook 'toggle-org-custom-inline-style)
;; (toggle-org-custom-inline-style)
;;;;; Github Autumn Files
;; Often times the export fails due to broken links
;; this setting prevents that
;; with org-roam sometimes the links are not even broken!
(setq org-export-with-broken-links t)

(setq org-publish-project-alist
      '(
;; (https://orgmode.org/worg/org-tutorials/org-publish-html-tutorial.html)
        ("Aut_orgfiles"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-html-publish-to-html
         :exclude ".*" ;; Regexp
         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
                   "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Aut_images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-publish-attachment)

        ("Aut_other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "~/Documents/ryangreenup.github.io/Org-Publish/"
         :publishing-function org-publish-attachment)

        ("Autumn" :components ("Aut_orgfiles" "Aut_images" "Aut_other"))

;;;;; Server Autumn Files

        ("Server_Org"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :index-filename "index.org"
         :auto-index t
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :publishing-directory "/srv/http/Org"
         :publishing-function org-html-publish-to-html
         :exclude "*jour.*" ;; Regexp
;;         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
 ;;                  "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Server_Images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Server_Other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Server" :components ("Server_Org" "Server_Images" "Server_Other"))

;;;;; Roam Files

        ("Roam_Org"
         :base-directory "~/Notes/Org/roam/"
         :base-extension "org"
         :index-filename "index.org"
         :auto-index t
         :auto-sitemap nil                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :publishing-directory "/srv/http/Org"
         :publishing-function org-html-publish-to-html
         :exclude "*jour.*" ;; Regexp
;;         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
 ;;                  "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 6
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Roam_Images"
         :base-directory "~/Notes/Org/roam"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Roam_Other"
         :base-directory "~/Notes/Org/roam"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "/srv/http/Org"
         :publishing-function org-publish-attachment)

        ("Roam" :components ("Roam_Org" "Roam_Images" "Roam_Other"))

;;;;; Local HTML Files

        ("Export_Org"
         :base-directory "~/Notes/Org/"
         :base-extension "org"
         :index-filename "index.org"
         :auto-index t
         :auto-sitemap t                ; Generate sitemap.org automagically...
         :sitemap-filename "sitemap.org"  ; ... call it sitemap.org (it's the default)...
         :sitemap-title "Sitemap"         ; ... with title 'Sitemap'.
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-html-publish-to-html
;;         :exclude "*jour.*" ;; Regexp
;;         :include ("./VisualAnalytics.org" "ThinkingAboutData.org"
 ;;                  "analytic_programming.org" "Social_Web_Analytics.org") ;; regexp ;; everything included otherwise
         :headline-levels 3
         :recursive t
         :section-numbers nil
         :with-toc t
         :html-head "<link rel=\"stylesheet\"
         href=\"./style.css\" type=\"text/css\"/>"
         :html-preamble t)


        ("Export_Images"
         :base-directory "~/Notes/Org/"
         :base-extension "jpg\\|gif\\|png"
         :exclude ".*ltximg.*" ;; regexp
         :recursive t
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-publish-attachment)

        ("Export_Other"
         :base-directory "~/Notes/Org/"
         :base-extension "css\\|el\\|pdf\\|rmd\\|r\\|R\\|sh"
         :exclude "journal.*" ;; Regexp
         :recursive t
         :publishing-directory "~/Notes/Org/export"
         :publishing-function org-publish-attachment)

        ("Export" :components ("Export_Org" "Export_Images" "Export_Other"))


        ))
;; todo, but be mindful to move apache from root
;; Ox-Hugo
;; If you do want to split an org-file up into multiple pieces look at these:
;; [[https://lists.gnu.org/archive/html/emacs-orgmode/2015-08/msg01283.html]]
;; [[https://github.com/mbork/org-one-to-many]]
;; (withheval-after-load 'ox
;;                       (require 'ox-hugo))





(provide 'init-org-publish)
;;; init-org-publish.el ends here
