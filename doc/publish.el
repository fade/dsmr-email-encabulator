;;; publish.el --- Build the DSMR stack documentation website  -*- lexical-binding: t; -*-
;;
;; Run at package build time:  emacs --batch -Q -l doc/publish.el
;;
;; Publishes the encabulator's org doc tree (doc/) — its own topic files plus
;; the per-package component manuals staged into doc/components/ by debian/rules
;; — into a single interlinked HTML site under site/.  org→org file links are
;; rewritten to .html automatically; .dsmr / image attachments are copied so
;; their links resolve too.  Build-time only.

(require 'ox-publish)
(require 'ox-html)

(setq make-backup-files nil
      org-html-validation-link nil
      org-export-with-broken-links t      ; a stale cross-ref must not fail the build
      org-export-with-toc 2
      org-export-with-section-numbers nil)

(let* ((root (directory-file-name default-directory))
       (docdir (expand-file-name "doc" root))
       (outdir (expand-file-name "site" root)))
  (setq org-publish-project-alist
        `(("dsmr-pages"
           :base-directory ,docdir
           :base-extension "org"
           :recursive t
           :publishing-directory ,outdir
           :publishing-function org-html-publish-to-html
           :with-toc 2
           :section-numbers nil
           :html-head-include-scripts nil
           :html-head-include-default-style t
           :auto-sitemap t
           :sitemap-filename "sitemap.org"
           :sitemap-title "DSMR Mail Stack — documentation index")
          ("dsmr-static"
           :base-directory ,docdir
           :base-extension "dsmr\\|txt\\|png\\|jpg\\|gif\\|css\\|svg"
           :recursive t
           :publishing-directory ,outdir
           :publishing-function org-publish-attachment)
          ("dsmr-site" :components ("dsmr-pages" "dsmr-static"))))
  (message "Publishing DSMR site: %s -> %s" docdir outdir)
  (org-publish "dsmr-site" t))
