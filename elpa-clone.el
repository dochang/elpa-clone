;;; elpa-clone.el --- Clone ELPA archive

;; Copyright (C) 2016 ZHANG Weiyi

;; Author: ZHANG Weiyi <dochang@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((cl-lib "0"))
;; Keywords: elpa, clone, mirror
;; URL: https://github.com/dochang/elpa-clone

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along with
;; this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Mirror an ELPA archive into a directory.

;; Prerequisites:
;;
;;   - Emacs 24
;;   - cl-lib

;; Installation:
;;
;; To install `elpa-clone' from git repository, clone the repo, then add the
;; repo dir into `load-path'.

;; Usage:
;;
;; To clone an ELPA archive `http://host/elpa' into `/path/to/elpa', invoke
;; `elpa-clone':
;;
;;     (elpa-clone "http://host/elpa" "/path/to/elpa")
;;
;; `elpa-clone' can also be invoked via `M-x'.

;; Note:
;;
;; `elpa-clone' does NOT overwrite existing files.  If a package file is
;; broken, remove the file and call `elpa-clone' again.

;; License:
;;
;; GPLv3

;;; Code:

(require 'url)
(require 'package)
(require 'cl-lib)


(defun elpa-clone--resolve-to (path base)
  (if (or (url-p base)
          (string-match-p "\\`https?:" base))
      (format "%s/%s" base path)
    (expand-file-name path
                      (if (file-name-absolute-p base)
                          base (expand-file-name base)))))

(defun elpa-clone--read-archive-contents (buffer)
  (let ((contents (read buffer)))
    (when (> (car contents) package-archive-version)
      (error "Package archive version %d is higher than %d"
             (car contents) package-archive-version))
    (cdr contents)))

(defun elpa-clone--package-filename (pkg)
  (let* ((pkg-desc
          (package-desc-create
           :name (car pkg)
           :version (aref (cdr pkg) 0)
           :kind (aref (cdr pkg) 3))))
    (concat (package-desc-full-name pkg-desc)
            (package-desc-suffix pkg-desc))))

(defun elpa-clone--downloader (upstream downstream)
  (lambda (filename)
    (let ((source (elpa-clone--resolve-to filename upstream))
          (target (expand-file-name filename downstream)))
      (unless (file-exists-p target)
        (if (string-match-p "\\`https?:" source)
            (url-copy-file source target)
          (copy-file source target))))))

;;;###autoload
(defun elpa-clone (upstream downstream)
  "Clone ELPA archive.

UPSTREAM is an ELPA URL.
DOWNSTREAM is the download directory."
  (interactive "sUpstream URL: \nGDownload directory: ")

  (when (url-p upstream)
    (setq upstream (url-recreate-url upstream)))

  (unless upstream
    (error "Upstream URL must NOT be nil!"))

  (unless downstream
    (error "Download directory must NOT be nil!"))

  (setq downstream (expand-file-name downstream))
  (make-directory downstream 'create-parents)
  (setq downstream (file-name-as-directory downstream))

  (let ((upstream-contents (elpa-clone--resolve-to "archive-contents" upstream))
        (downstream-contents (expand-file-name "archive-contents" downstream))
        (make-backup-files nil)
        (version-control 'never))
    (with-temp-buffer
      (if (string-match-p "\\`https?:" upstream-contents)
          (url-insert-file-contents upstream-contents)
        (insert-file-contents upstream-contents))
      (goto-char (point-min))
      (let ((pkgs (elpa-clone--read-archive-contents (current-buffer))))
        (write-file downstream-contents)
        (let* ((upstream-filenames (mapcar 'elpa-clone--package-filename pkgs))
               (downstream-filenames (directory-files downstream nil
                                                      "\\.\\(el\\|tar\\)$"))
               (outdate-filenames (cl-set-difference downstream-filenames
                                                     upstream-filenames
                                                     :test 'string=))
               (new-filenames (cl-set-difference upstream-filenames
                                                 downstream-filenames
                                                 :test 'string=))
               (downloader (elpa-clone--downloader upstream downstream))
               (cleaner (lambda (filename)
                          (delete-file (expand-file-name filename downstream)))))
          (mapc cleaner outdate-filenames)
          (mapc downloader new-filenames))))))

(provide 'elpa-clone)

;;; elpa-clone.el ends here
