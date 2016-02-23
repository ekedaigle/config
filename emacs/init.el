(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(setq use-package-verbose t)
(setq use-package-always-ensure t)

(require 'use-package)

(use-package evil
    :init
    (setq evil-want-C-u-scroll t)
    :config
    (evil-mode 1))

(tool-bar-mode -1)
(menu-bar-mode -1)
(setq vc-follow-symlinks t)
(setq scroll-conservatively 10000)
(setq scroll-margin 3)

(add-to-list 'custom-theme-load-path "~/config/emacs/emacs-color-theme-solarized")
(set-frame-parameter nil 'background-mode 'dark)
(set-terminal-parameter nil 'background-mode 'dark)
(load-theme 'solarized t)

(add-to-list 'load-path "~/config/emacs")
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")

(use-package key-chord
    :config
    (key-chord-mode 1)
    (key-chord-define evil-insert-state-map "jk" 'evil-normal-state))

(global-linum-mode)

(use-package highlight-numbers
    :config
    (add-hook 'prog-mode-hook 'highlight-numbers-mode))
    
(use-package company
    :config
    (add-hook 'after-init-hook 'global-company-mode))
    
(use-package company-irony
    :config
    (eval-after-load 'company
	'(add-to-list 'company-backends 'company-irony)))

(use-package jedi
    :config
    (add-hook 'python-mode-hook 'jedi:setup)
    (setq jedi:complete-on-dot t))
    
(use-package irony
    :config
    (add-hook 'c++-mode-hook 'irony-mode)
    (add-hook 'c-mode-hook 'irony-mode)
    (add-hook 'objc-mode-hook 'irony-mode)
    (defun my-irony-mode-hook ()
	(define-key irony-mode-map [remap completion-at-point]
	    'irony-completion-at-point-async)
	(define-key irony-mode-map [remap complete-symbol]
	    'irony-completion-at-point-async))
    (add-hook 'irony-mode-hook 'my-irony-mode-hook)
    (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package evil-nerd-commenter
    :config
    (evil-leader/set-key
        "ci" 'evilnc-comment-or-uncomment-lines
        "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
        "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
        "cc" 'evilnc-copy-and-comment-lines
        "cp" 'evilnc-comment-or-uncomment-paragraphs
        "cr" 'comment-or-uncomment-region
        "cv" 'evilnc-toggle-invert-comment-line-by-line
        "\\" 'evilnc-comment-operator ; if you prefer backslash key
    )   
)
    
(defun my-c-mode-common-hook()
    (setq tab-width 4)
    (setq c-basic-offset 4)
    (setq c-indent-level 4)
    
    ; make underscore part of words
    (modify-syntax-entry ?_ "w")
)
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

; use spaces instead of tabs
(setq-default indent-tabs-mode nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-builtin-face ((t (:foreground "brightblue"))))
 '(font-lock-variable-name-face ((t (:foreground "brightblue"))))))
