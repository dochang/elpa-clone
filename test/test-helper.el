(require 'f)
(require 'simple-httpd)

;; Do not truncate the backtrace.  This makes ERT easy to debug.
(setq ert-batch-backtrace-right-margin 256)

(defvar test-path
  (f-dirname load-file-name)
  "Path to test directory.")

(defvar fixture-root
  (f-join test-path "fixtures")
  "Path to fixture root directory.")
