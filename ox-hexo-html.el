;;; ox-hexo-html.el --- Export org-mode to hexo HTML.

;; Copyright (c) 2015 Yen-Chin, Lee. (coldnew) <coldnew.tw@gmail.com>
;;
;; Author: coldnew <coldnew.tw@gmail.com>
;; Keywords:
;; X-URL: http://github.com/coldnew/org-hexo
;; Version: 0.1
;; Package-Requires: ((org "8.0") (cl-lib "0.5") (f "0.17.2") (noflet "0.0.11"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl-lib))

(require 'f)
(require 'ox-html)
(require 'ox-publish)

(require 'ox-hexo-core)


;;;; Backend

(org-export-define-derived-backend 'hexo-html 'html
  :translate-alist
  '(;; drop most of nouse html header
    (template . org-hexo-html-template)
    ;; Fix for multibyte language
    (paragraph . org-hexo-html-paragraph)
    ;; Fix toc for org-hexo theme
    (inner-template . org-hexo-html-inner-template)
    ;; convert relative link to let pelican can recognize
    (link . org-hexo-html-link)
    )
  :options-alist org-hexo--options-alist)


;;;; Paragraph

(defun org-hexo-html-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into Markdown format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  (org-hexo--paragraph 'org-html-paragraph
                       paragraph contents info))


;;; Template

(defun org-hexo-html-inner-template (contents info)
  "Return body of document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   ;; Document contents.
   contents
   ;; Footnotes section.
   (org-html-footnote-section info)))


;;;; Link

(defun org-hexo-html-link (link desc info)
  "Transcode a LINK object from Org to HTML.

DESC is the description part of the link, or the empty string.
INFO is a plist holding contextual information.  See
`org-export-data'.

In this function, we also add link file"
  (let ((org-html-link-org-files-as-html nil)
        (html-link (org-hexo--link 'org-html-link link desc info)))
    ;; FIXME:
    ;; Remove alt in image
    ;;        class in link
    (replace-regexp-in-string
     "<a href=\"\\(.*?\\)\"\s+class=\"\\(.*?\\)\"\\(.*?\\)" "<a href=\"\\1\" \\3"
     (replace-regexp-in-string
      "<img src=\"\\(.*?\\)\"\s+alt=\"\\(.*?\\)\"\\(.*?\\)" "<img src=\"\\1\" \\3" html-link))))


;;; Template

(defun org-hexo-html-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   ;; Add yml meta info
   ;;(org-hexo-md--build-meta-info info)
   (org-hexo--build-front-matter info)
   ;; start html header
   (org-html-doctype info)
   "\n"
   "<head>\n"
   ;;(org-hexo-html--build-meta-info info)
   "</head>\n"
   "<body>\n"

   ;; Document contents.
   (format "<%s id=\"%s\">\n"
           (nth 1 (assq 'content org-html-divs))
           (nth 2 (assq 'content org-html-divs)))

   contents
   (format "</%s>\n"
           (nth 1 (assq 'content org-html-divs)))

   ;; Closing document.
   "</body>\n</html>"))


;;; End-user functions

;;;###autoload
(defun org-hexo-export-as-html
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to an HTML buffer for org-hexo.

Export is done in a buffer named \"*Hexo HTML Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-export-to-buffer 'hexo-html "*Hexo HTML Export*"
    async subtreep visible-only body-only ext-plist
    (lambda () (html-mode))))

;;;###autoload
(defun org-hexo-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'hexo-html filename
                      (concat "." (or (plist-get plist :html-extension)
                                      org-html-extension "html"))
                      plist pub-dir))

(provide 'ox-hexo-html)
;;; ox-hexo-html.el ends here.
