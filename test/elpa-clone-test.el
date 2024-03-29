(require 'f)
(require 'simple-httpd)
(require 'elpa-clone)

(ert-deftest test-0001-local-clone ()
  (let* ((fixture-name "0001-local-clone")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "b-2.tar")))))

(ert-deftest test-0002-local-clone-broken ()
  (let* ((fixture-name "0002-local-clone-broken")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (should-error (elpa-clone source target)
                  :type 'end-of-file)
    (should-not (f-file? (f-join target "archive-contents")))
    (should-not (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "b-2.tar")))))

(ert-deftest test-0003-http-clone ()
  (let* ((fixture-name "0003-http-clone")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name))
         (httpd-port 10003))
    (httpd-serve-directory source)
    (unwind-protect
        (progn
          (elpa-clone "http://127.0.0.1:10003" target)
          (should (f-file? (f-join target "archive-contents")))
          (should (f-file? (f-join target "a-1.el")))
          (should (f-file? (f-join target "b-2.tar"))))
      (httpd-stop))))

(ert-deftest test-0004-signature ()
  (let* ((fixture-name "0004-signature")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "archive-contents.sig")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "a-1.el.sig")))
    (should (f-file? (f-join target "b-2.tar")))
    (should (f-file? (f-join target "b-2.tar.sig")))))

(ert-deftest test-0005-signature-lost ()
  (let* ((fixture-name "0005-signature-lost")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (should-error (elpa-clone source target)
                  :type 'file-error)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "archive-contents.sig")))
    (should-not (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "a-1.el.sig")))))

(ert-deftest test-0006-split-filename ()
  (should (equal (elpa-clone--split-filename "foo-bar-1.0-git.el")
                 (list "foo-bar" "1.0-git")))
  (should (equal (elpa-clone--split-filename "foo-bar-1.0-.el")
                 (list "foo-bar" "1.0-")))
  (should (equal (elpa-clone--split-filename "foo-bar.el")
                 (list "foo-bar")))
  (should (equal (elpa-clone--split-filename "baz/foo-bar-1.0.el")
                 (list "foo-bar" "1.0"))))

(ert-deftest test-0007-readme ()
  (let* ((fixture-name "0007-readme")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (elpa-clone source target)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "a-readme.txt")))
    (should (f-file? (f-join target "b-2.tar")))
    (should (f-file? (f-join target "b-readme.txt")))))

(ert-deftest test-0008-signature-never ()
  (let* ((fixture-name "0008-signature-never")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (elpa-clone source target :signature 'never)
    (should (f-file? (f-join target "archive-contents")))
    (should-not (f-file? (f-join target "archive-contents.sig")))
    (should (f-file? (f-join target "a-1.el")))
    (should-not (f-file? (f-join target "a-1.el.sig")))
    (should (f-file? (f-join target "b-2.tar")))
    (should-not (f-file? (f-join target "b-2.tar.sig")))))

(ert-deftest test-0009-select-sync-method ()
  (should (eq (elpa-clone--select-sync-method "http://localhost:10009") 'url))
  (should (eq (elpa-clone--select-sync-method "file:///path/to/") 'url))
  (should (eq (elpa-clone--select-sync-method "rsync://host") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host:/path/to") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host:path/to") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host:") 'rsync))
  (should (eq (elpa-clone--select-sync-method "user@host:/path/to") 'rsync))
  (should (eq (elpa-clone--select-sync-method "user@host:path/to") 'rsync))
  (should (eq (elpa-clone--select-sync-method "user@host:") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host::mod") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host::mod/path/to") 'rsync))
  (should (eq (elpa-clone--select-sync-method "host::") 'rsync))
  (should (eq (elpa-clone--select-sync-method "/path/to") 'local)))

(ert-deftest test-0010-rsync-clone ()
  (let* ((fixture-name "0010-rsync-clone")
         (source (f-join source-root fixture-name))
         (target (f-join target-root fixture-name)))
    (elpa-clone (file-name-as-directory source) target :sync-method 'rsync)
    (should (f-file? (f-join target "archive-contents")))
    (should (f-file? (f-join target "a-1.el")))
    (should (f-file? (f-join target "b-2.tar")))))
