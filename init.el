;;; init.el --- Lucas Cesar's Emacs configuration
;;
;; Copyright (c) 2025-2026 Lucas Cesar
;;
;; Author: Lucas Cesar <9426068@aluno.uniasselvi.com.br>
;; URL: https://github.com/juslucascesar/emacs.d
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This is my personal Emacs configuration.  Nothing more, nothing less.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


;; basics
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)

(setq gc-cons-threshold (* 100 1024 1024))

(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(setq user-full-name "Lucas Cesar"
      user-mail-address "9426068@aluno.uniasselvi.com.br")

(setenv "SSH_AUTH_SOCK" (getenv "SSH_AUTH_SOCK"))

;; (setq backup-by-copying t)

(setq native-comp-async-report-warnings-errors 'silent)

(setq byte-compile-warnings
      '(not obsolete))

(setq load-prefer-newer t)

(setq confirm-kill-processes nil)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(global-auto-revert-mode t)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; package system
(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("org"    . "https://orgmode.org/elpa/")
        ("melpa"  . "https://melpa.org/packages/")))

(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; install use-package (if missing)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; use-package
(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)

;;(defvar my/packages
;;  '(use-package org org-roam org-ref auctex pdf-tools counsel
;;    dashboard ivy projectile magit which-key orderless vertico
;;    marginalia deft swiper modus-themes))

;;(dolist (pkg my/packages)
;;  (unless (package-installed-p pkg)
;;    (package-install pkg)))

;; research structure
(defvar research-dir "~/Documents/Research/")
(defvar articles-dir (concat research-dir "articles/"))
(defvar notes-dir (concat research-dir "notes/"))
(defvar cases-dir (concat notes-dir "cases/"))
(defvar doctrine-dir (concat notes-dir "doctrine/"))
(defvar pdfs-dir (concat research-dir "pdfs/"))
(defvar biblio-file (concat research-dir "biblio.bib"))
(defvar biblio-notes (concat research-dir "biblio-notes.org"))

(dolist (dir (list research-dir articles-dir notes-dir cases-dir doctrine-dir pdfs-dir))
  (unless (file-exists-p dir)
    (make-directory dir t)))

;; theme
(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi t)

;;  (setq modus-themes-italic-constructs t
;;        modus-themes-bold-constructs t
;;        modus-themes-region '(bg-only no-extend))
;;  
;;  (modus-themes-org-blocks 'gray-background)
;;  (modus-themes-org-agenda '((header . (variable-pitch scale))))
)

;; dashboard
(use-package dashboard
  :config
  (setq dashboard-startup-banner 'official
        dashboard-center-content t
        dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)))
  (dashboard-setup-startup-hook))

;; magit & which-key
(use-package magit
  :bind ("C-x g" . magit-status))

(use-package which-key
  :init (which-key-mode))

;; completion system
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil))

(use-package marginalia
  :init (marginalia-mode))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        enable-recursive-minibuffers t
        ivy-count-format "(%d/%d) "))

(use-package counsel
  :after ivy
  :config (counsel-mode 1))

(use-package swiper
  :after ivy)

;; org-mode
(use-package org
  :pin org
  :config
  (setq org-startup-indented t))

(setq org-directory notes-dir)
(setq org-default-notes-file (concat org-directory "/notes.org"))
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; org-roam & templates
(use-package org-roam
  :init (setq org-roam-v2-ack t)
  :custom (org-roam-directory notes-dir)
  :bind
   (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n g" . org-roam-graph)
   ("C-c n c" . org-roam-capture)
   ("C-c n l" . org-roam-buffer-toggle))
  :config (org-roam-db-autosync-mode))

(setq org-roam-capture-templates
      '(("a" "Artigo científico" plain
         "* Resumo\n%?\n\n* Palavras-chave\n\n* Introdução\n\n* Desenvolvimento\n\n* Conclusão\n\n* Referências"
         :if-new (file+head "../articles/${slug}/${slug}.org" "#+title: ${title}\n#+author: ${author}\n#+date: %U\n")
         :unnarrowed t)
	("c" "Caso / Jurisprudência" plain
         "* ${title}\n:PROPERTIES:\n:Tipo: Caso\n:Autoridade: \n:Data: \n:Link: \n:END:\n\n** Resumo\n%?\n\n** Comentários\n\n** Citações\n"
         :if-new (file+head "cases/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+TITLE: ${title}\n#+DATE: %U\n#+ROAM_KEY: ${slug}\n")
         :unnarrowed t)
        ("d" "Doutrina / Artigo" plain
         "* ${title}\n:PROPERTIES:\n:Tipo: Doutrina\n:Autor: \n:Ano: \n:Link: \n:END:\n\n** Resumo\n%?\n\n** Comentários\n\n** Citações\n"
         :if-new (file+head "doctrine/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+TITLE: ${title}\n#+DATE: %U\n#+ROAM_KEY: ${slug}\n")
         :unnarrowed t)
        ("j" "Nota Jurídica" plain
         "%?"
         :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+TITLE: ${title}\n#+DATE: %U\n#+ROAM_KEY: ${slug}\n")
         :unnarrowed t)))


;; org-ref & zotero integration
(use-package org-ref
  :custom
  (org-ref-bibliography-notes biblio-notes)
  (org-ref-default-bibliography (list biblio-file))
  (org-ref-pdf-directory pdfs-dir)
  :config (require 'doi-utils))

(global-set-key (kbd "C-c ]") 'org-ref-insert-cite-link)

;; pdf tools
(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq pdf-view-display-size 'fit-page))

(setq auto-mode-alist
      (append '(("\\.pdf\\'" . pdf-view-mode)) auto-mode-alist))

(global-set-key (kbd "C-c p") 'pdf-view-mode)
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

;; (la/auc)tex
(use-package tex
  :ensure auctex
  :defer t
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-PDF-mode t))

(setq org-latex-pdf-process
      '("xelatex -interaction nonstopmode -output-directory %o %f"
        "xelatex -interaction nonstopmode -output-directory %o %f"))

;; quick notes
(use-package deft
  :commands (deft)
  :custom
  (deft-directory notes-dir)
  (deft-recursive t)
  (deft-use-filename-as-title t))

(global-set-key (kbd "C-c d") 'deft)

;; performance
(defun my/increase-gc ()
  (setq gc-cons-threshold (* 100 1024 1024)))
(defun my/decrease-gc ()
  (setq gc-cons-threshold (* 20 1024 1024)))
(advice-add 'org-roam-db-sync :around
            (lambda (orig-fn &rest args)
              (my/increase-gc)
              (apply orig-fn args)
              (my/decrease-gc)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(modus-themes deft marginalia vertico orderless which-key magit projectile dashboard counsel pdf-tools org-roam org-ref ivy auctex)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
