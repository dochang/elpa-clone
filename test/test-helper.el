(require 'f)
(require 'web-server)

;; Do not truncate the backtrace.  This makes ERT easy to debug.
(setq ert-batch-backtrace-right-margin 256)

(defvar test-path
  (f-dirname load-file-name)
  "Path to test directory.")

(defvar fixture-root
  (f-join test-path "fixtures")
  "Path to fixture root directory.")

(defun make-static-handler (source)
  (lambda (request)
    (with-slots (process headers) request
      (let ((path (substring (cdr (assoc :GET headers)) 1)))
        (if (ws-in-directory-p source path)
            (if (file-directory-p path)
                (ws-send-directory-list process
                                        (f-join source path)
                                        "^[^\.]")
              (ws-send-file process (f-join source path)))
          (ws-send-404 process))))))
