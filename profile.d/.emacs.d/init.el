;; Bootstrap then init (so you can use bootstrapped stuff in init).

;; less broken


(defmacro mapply (f &rest rest)
  `(let ((result "done"))
     (message "%s..." ,f)
     (unwind-protect (apply ,f ,@rest) (setq result "failed"))
     (message "%s...%s" ,f result)))
  

(defun bootstrap-quelpa()
  "https://github.com/quelpa/quelpa"
  (unless (package-installed-p 'quelpa)
    (with-temp-buffer
      (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
      (eval-buffer)
      (quelpa-self-upgrade))))

(defun bootstrap-melpa()
  "https://melpa.org/#/getting-started"
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
  (package-initialize))

(defun bootstrap-straight()
  "https://github.com/radian-software/straight.el"
  (defvar bootstrap-version)
  (let ((bootstrap-file
         (expand-file-name
          "straight/repos/straight.el/bootstrap.el"
          (or (bound-and-true-p straight-base-dir)
              user-emacs-directory)))
        (bootstrap-version 7))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
           "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
           'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage)))

;; elisp linked data, tbd
(defmacro elld(&rest rest))

(defun bootstrap-elpaca()
  (defvar elpaca-installer-version 0.7)
  (defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
  (defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
  (defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
  (defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                                :ref nil :depth 1
                                :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                                :build (:not elpaca--activate-package)))
  (let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
         (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
    (add-to-list 'load-path (if (file-exists-p build) build repo))
    (unless (file-exists-p repo)
      (make-directory repo t)
      (when (< emacs-major-version 28) (require 'subr-x))
      (condition-case-unless-debug err
          (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                   ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                   ,@(when-let ((depth (plist-get order :depth)))
                                                       (list (format "--depth=%d" depth) "--no-single-branch"))
                                                   ,(plist-get order :repo) ,repo))))
                   ((zerop (call-process "git" nil buffer t "checkout"
                                         (or (plist-get order :ref) "--"))))
                   (emacs (concat invocation-directory invocation-name))
                   ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                         "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                   ((require 'elpaca))
                   ((elpaca-generate-autoloads "elpaca" repo)))
              (progn (message "%s" (buffer-string)) (kill-buffer buffer))
            (error "%s" (with-current-buffer buffer (buffer-string))))
        ((error) (warn "%s" err) (delete-directory repo 'recursive))))
    (unless (require 'elpaca-autoloads nil t)
      (require 'elpaca)
      (elpaca-generate-autoloads "elpaca" repo)
      (load "./elpaca-autoloads")))
  (add-hook 'after-init-hook #'elpaca-process-queues)
  (elpaca `(,@elpaca-order))
  (elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode)))



(defun bootstrap-emacs()
  ;; (bootstrap-quelpa)
  ;; (bootstrap-elpaca))
  ;; (bootstrap-melpa))
  (bootstrap-straight))

;; (defun use-lean4-mode()
;;   (use-package lean4-mode
;;     :straight (lean4-mode
;; 	       :type git
;; 	       :host github
;; 	       :repo "leanprover/lean4-mode"
;; 	       :files ("*.el" "data"))
;;     ;; to defer loading the package until required
;;     :commands (lean4-mode)))
  
(defun bootstrap-treemacs()
  "https://github.com/Alexander-Miller/treemacs#installation"
  (use-package treemacs
	     :ensure t
	     :defer t
	     :init
	     (with-eval-after-load 'winum
	       (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
	     :config
	     (progn
	       (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
		     treemacs-deferred-git-apply-delay        0.5
		     treemacs-directory-name-transformer      #'identity
		     treemacs-display-in-side-window          t
		     treemacs-eldoc-display                   'simple
		     treemacs-file-event-delay                2000
		     treemacs-file-extension-regex            treemacs-last-period-regex-value
		     treemacs-file-follow-delay               0.2
		     treemacs-file-name-transformer           #'identity
		     treemacs-follow-after-init               t
		     treemacs-expand-after-init               t
		     treemacs-find-workspace-method           'find-for-file-or-pick-first
		     treemacs-git-command-pipe                ""
		     treemacs-goto-tag-strategy               'refetch-index
		     treemacs-header-scroll-indicators        '(nil . "^^^^^^")
		     treemacs-hide-dot-git-directory          t
		     treemacs-indentation                     2
		     treemacs-indentation-string              " "
		     treemacs-is-never-other-window           nil
		     treemacs-max-git-entries                 5000
		     treemacs-missing-project-action          'ask
		     treemacs-move-forward-on-expand          nil
		     treemacs-no-png-images                   nil
		     treemacs-no-delete-other-windows         t
		     treemacs-project-follow-cleanup          nil
		     treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
		     treemacs-position                        'left
		     treemacs-read-string-input               'from-child-frame
		     treemacs-recenter-distance               0.1
		     treemacs-recenter-after-file-follow      nil
		     treemacs-recenter-after-tag-follow       nil
		     treemacs-recenter-after-project-jump     'always
		     treemacs-recenter-after-project-expand   'on-distance
		     treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
		     treemacs-project-follow-into-home        nil
		     treemacs-show-cursor                     nil
		     treemacs-show-hidden-files               t
		     treemacs-silent-filewatch                nil
		     treemacs-silent-refresh                  nil
		     treemacs-sorting                         'alphabetic-asc
		     treemacs-select-when-already-in-treemacs 'move-back
		     treemacs-space-between-root-nodes        t
		     treemacs-tag-follow-cleanup              t
		     treemacs-tag-follow-delay                1.5
		     treemacs-text-scale                      nil
		     treemacs-user-mode-line-format           nil
		     treemacs-user-header-line-format         nil
		     treemacs-wide-toggle-width               70
		     treemacs-width                           35
		     treemacs-width-increment                 1
		     treemacs-width-is-initially-locked       t
		     treemacs-workspace-switch-cleanup        nil)

	       ;; The default width and height of the icons is 22 pixels. If you are
	       ;; using a Hi-DPI display, uncomment this to double the icon size.
	       ;;(treemacs-resize-icons 44)

	       (treemacs-follow-mode t)
	       (treemacs-filewatch-mode t)
	       (treemacs-fringe-indicator-mode 'always)
	       (when treemacs-python-executable
		 (treemacs-git-commit-diff-mode t))

	       (pcase (cons (not (null (executable-find "git")))
			    (not (null treemacs-python-executable)))
		 (`(t . t)
		  (treemacs-git-mode 'deferred))
		 (`(t . _)
		  (treemacs-git-mode 'simple)))

	       (treemacs-hide-gitignored-files-mode nil))
	     :bind
	     (:map global-map
		   ("M-0"       . treemacs-select-window)
		   ("C-x t 1"   . treemacs-delete-other-windows)
		   ("C-x t t"   . treemacs)
		   ("C-x t d"   . treemacs-select-directory)
		   ("C-x t B"   . treemacs-bookmark)
		   ("C-x t C-t" . treemacs-find-file)
		   ("C-x t M-t" . treemacs-find-tag)))

  (use-package treemacs-evil
	       :after (treemacs evil)
	       :ensure t)

  (use-package treemacs-projectile
	       :after (treemacs projectile)
	       :ensure t)

  (use-package treemacs-icons-dired
	       :hook (dired-mode . treemacs-icons-dired-enable-once)
	       :ensure t)

  (use-package treemacs-magit
	       :after (treemacs magit)
	       :ensure t)

  (use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
	       :after (treemacs persp-mode) ;;or perspective vs. persp-mode
	       :ensure t
	       :config (treemacs-set-scope-type 'Perspectives))

  (use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
	       :after (treemacs)
	       :ensure t
	       :config (treemacs-set-scope-type 'Tabs)))




;; init

(defun bootstrap-typescript()
  "https://vxlabs.com/2022/06/12/typescript-development-with-emacs-tree-sitter-and-lsp-in-2022/"

  ;; https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter
  ;; https://www.reddit.com/r/emacs/comments/zbpa42/how_to_use_emacs_29_treesitter/
  (use-package tree-sitter
    :ensure t
    :config
    ;; activate tree-sitter on any buffer containing code for which it has a parser available
    (global-tree-sitter-mode)
    ;; you can easily see the difference tree-sitter-hl-mode makes for python, ts or tsx
    ;; by switching on and off
    (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

  (use-package tree-sitter-langs
    :ensure t
    :after tree-sitter)

  ;; https://github.com/orzechowskid/tsi.el/
  ;; great tree-sitter-based indentation for typescript/tsx, css, json
  (use-package tsi
    :after tree-sitter
    ;; :quelpa (tsi :fetcher github :repo "orzechowskid/tsi.el")
    ;; define autoload definitions which when actually invoked will cause package to be loaded
    :commands (tsi-typescript-mode tsi-json-mode tsi-css-mode)
    :init)
    (add-hook 'typescript-mode-hook (lambda () (tsi-typescript-mode 1)))
    (add-hook 'json-mode-hook (lambda () (tsi-json-mode 1)))
    (add-hook 'css-mode-hook (lambda () (tsi-css-mode 1)))
    (add-hook 'scss-mode-hook (lambda () (tsi-scss-mode 1))))

  ;; auto-format different source code files extremely intelligently
  ;; https://github.com/radian-software/apheleia
  ;; (use-package apheleia :config (apheleia-global-mode +1)))


;; Set the default font height. Abstracts emacs "faces".
(defconst *default-height* 200)
(defun init-height(&optional height)
  "Set the default font height to `height` or *default-height* if no argument."
  (set-face-attribute 'default nil :height (or height *default-height*)))

(defun init-tweaks(&optional font-height)                                        
  "Tweak emacs, mostly appearance."
  (init-height font-height) ; increase the font size
  (pixel-scroll-mode) ; turns on
  (setq-default indent-tabs-mode nil))

(defun init-markdown-mode()
  "Initialize markdown-mode installed via elpaca."  
  (elld (:id 'markdown-mode :tutorial "https://leanpub.com/markdown-mode/read"))
  (elld (:id 'markdown-mode :summary "https://jblevins.org/projects/markdown-mode/")))
  ;; https://github.com/jwiegley/use-package
  ;; (elpaca-use-package markdown-mode :mode ("\\.md" . markdown-mode)))
  ;; TODO mike@carif.io: shouldn't markdown-mode update auto-mode-alist?
  ;; (add-to-list 'auto-mode-alist '("\\.md" . markdown-mode)))

(defun init-yaml-mode()
  "Initialize yaml-mode from install via elpaca."
  ;;(elpaca-use-package yaml-mode :mode ("\\.yaml" . yaml-mode)))
  ;; (add-to-list 'auto-mode-alist 
)

;; how to actually bootstrap new packages?
(defun init-magit()
  (use-package magit
    :bind (("C-x g" . magit-status)
           ("C-x C-g" . magit-status))))
  
(defun init-gleam-mode-up()
  (use-package gleam-mode :load-path "/home/mcarifio/src/gleam-mode"))

(defun init-gleam-mode()
  (add-to-list 'load-path "/home/mcarifio/src/gleam-mode")
  (load-library "gleam-mode"))


;; (defun use-treesit-jump()
;;   "https://github.com/dmille56/treesit-jump"
;;   (use-package treesit-jump
;;     :straight (:host github :repo "dmille56/treesit-jump" :files ("*.el" "treesit-queries"))
;;     :config
;;     ;; Optional: add some queries to filter out of results (since they can be too cluttered sometimes)
;;     (setq treesit-jump-queries-filter-list '("inner" "test" "param"))))

(defun customize()
  (custom-set-variables '(package-selected-packages '(yaml-mode use-package quelpa markdown-mode magit)))
  (custom-set-faces))


(defun init-emacs()
  (bootstrap-emacs)
  ;; (bootstrap-treemacs)
  ;; (init-magit)
  (customize)
  (init-height)
  (init-tweaks)
  (init-yaml-mode)
  (init-markdown-mode))
  ;;(init-gleam-mode)
  ;;(use-treesit-jump))
  ;; (elpaca-wait))

(init-emacs)
