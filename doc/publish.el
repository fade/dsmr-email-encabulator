;;; publish.el --- Build the DSMR stack documentation website  -*- lexical-binding: t; -*-
;;
;; Run at package build time:  emacs --batch -Q -l doc/publish.el
;;
;; Publishes the encabulator's org doc tree (doc/) — its own topic files plus
;; the per-package component manuals staged into doc/components/ by debian/rules
;; — into a single interlinked HTML site under site/, styled with a vendored,
;; offline copy of Water.css (a minimal classless stylesheet, MIT-licensed).
;; org→org file links are rewritten to .html automatically; .dsmr / image
;; attachments and the stylesheet are copied alongside.  Build-time only.
;;
;; The stylesheet link is depth-relative: site-root pages reference style.css in
;; the same directory; one-level subdir pages (common/, components/) reference
;; ../style.css.

(require 'ox-publish)
(require 'ox-html)

(setq make-backup-files nil
      org-html-validation-link nil
      org-export-with-broken-links t        ; a stale cross-ref must not fail the build
      org-export-with-toc 2
      org-export-with-section-numbers nil
      ;; Identifiers like UPGRADE_LEGACY or tcp_smtp must render verbatim, not
      ;; with "_x" turned into a subscript.
      org-export-with-sub-superscripts nil
      org-html-doctype "html5"
      ;; Keep html5-fancy OFF: with it on, org emits the table of contents as a
      ;; <nav>, which classless CSS frameworks style as a padded flex menu bar.
      ;; A plain <div><ul> TOC styles as an ordinary bulleted list.
      org-html-html5-fancy nil
      ;; Emit semantic <header>/<main>/<footer> wrappers.
      org-html-divs '((preamble  "header" "preamble")
                      (content   "main"   "content")
                      (postamble "footer" "postamble")))

(defun dsmr--head (css)
  "HTML <head> additions linking the vendored stylesheet at CSS, plus a little
content-oriented polish (a normal bulleted TOC and a dimmed export footer)."
  (concat
   "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
   "<link rel=\"stylesheet\" href=\"" css "\">\n"
   "<style>\n"
   "#table-of-contents{margin:0 0 2rem}\n"
   "#text-table-of-contents ul{list-style:disc}\n"
   "#postamble{margin-top:3rem;font-size:.85em;opacity:.7}\n"
   "</style>"))

(let* ((root (directory-file-name default-directory))
       (docdir (expand-file-name "doc" root))
       (outdir (expand-file-name "site" root))
       (base '(:base-extension "org"
               :recursive nil
               :section-numbers nil
               :with-toc 2
               :html-head-include-scripts nil
               :html-head-include-default-style nil
               :publishing-function org-html-publish-to-html)))
  (setq org-publish-project-alist
        `(("dsmr-root"
           :base-directory ,docdir
           :publishing-directory ,outdir
           :html-head ,(dsmr--head "style.css")
           ,@base)
          ("dsmr-common"
           :base-directory ,(expand-file-name "common" docdir)
           :publishing-directory ,(expand-file-name "common" outdir)
           :html-head ,(dsmr--head "../style.css")
           ,@base)
          ("dsmr-components"
           :base-directory ,(expand-file-name "components" docdir)
           :publishing-directory ,(expand-file-name "components" outdir)
           :html-head ,(dsmr--head "../style.css")
           ,@base)
          ("dsmr-static"
           :base-directory ,docdir
           :base-extension "dsmr\\|png\\|jpg\\|gif\\|svg\\|txt"
           :recursive t
           :publishing-directory ,outdir
           :publishing-function org-publish-attachment)
          ("dsmr-site" :components ("dsmr-root" "dsmr-common" "dsmr-components" "dsmr-static"))))
  ;; Ship the stylesheet at the site root under the linked name.
  (make-directory outdir t)
  (copy-file (expand-file-name "water.css" docdir)
             (expand-file-name "style.css" outdir) t)
  (message "Publishing DSMR site (Water.css): %s -> %s" docdir outdir)
  (org-publish "dsmr-site" t))
