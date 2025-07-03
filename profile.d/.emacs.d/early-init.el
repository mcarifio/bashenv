;; -*- lexical-binding: t; -*-

;; https://github.com/emacs-ng/emacs-ng#:~:text=Just%20put%20this,at-startup%20t)
;; https://emacs-ng.github.io/emacs-ng/handbook/getting-started/
;; (setq ng-straight-bootstrap-at-startup t)

;; https://jeffkreeftmeijer.com/emacs-straight-use-package/

(defun init-straight() 
  (defvar bootstrap-version)
  (let ((bootstrap-file
         (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
        (bootstrap-version 7))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage))

  ;; Tell use-package to use straight.el by default
  (straight-use-package 'use-package)
  (setq straight-use-package-by-default t)
  
  (setq package-enable-at-startup nil)
  (setq use-package-always-ensure t))

(init-straight)
       

