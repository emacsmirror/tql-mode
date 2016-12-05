;;; tql-mode.el --- TQL mode
;; Copyright (C) 2017 Sean McLaughlin

;; Author: Sean McLaughlin <seanmcl@gmail.com>
;; Version: 0.1
;; Keywords: languages, TQL
;; Package-Requires: ((emacs "24"))

;;; Commentary:
;; TQL is a language for reasoning about networks.
;; tql-mode gives syntax highlighting and indentation for TQL files.

;;; Code:

(require 'smie)

(setq tql-mode-highlights
      '(("\\_<[A-Z][-a-zA-Z0-9/_]*" . font-lock-variable-name-face)
        ("\\[\\\([-a-zA-Z0-9/_ ]+\\)\\]" . (1 font-lock-preprocessor-face))
        ("\\(let\\|\\def\\)\s+\\([-a-zA-Z0-9/_]+\\)(" . (2 font-lock-type-face))
        ("\\bdef\\b\\|\\ball\\b\\|\\bex\\b\\|<=>\\|=>\\|&&\\|||\\|\\blet\\b\\|\\bin\\b\\|=" . font-lock-keyword-face)
        ("\\btrue\\b\\|\\bfalse\\b\\|\\blist\\b\\|\\bcount\\b" . font-lock-keyword-face)
        ("\\([-a-zA-Z0-9/_]+\\)(" . (1 font-lock-function-name-face))))

(defvar tql-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'tql-run-current-query)
    map)
  "Keymap for `tql-mode'.")

;;;###autoload
(define-derived-mode tql-mode fundamental-mode
  (setq font-lock-defaults '(tql-mode-highlights))
  (setq mode-name "tql")
  (tql-init))

(defconst tql-grammar
  (smie-prec2->grammar
   (smie-merge-prec2s
    (smie-bnf->prec2
     '((id)
       (decl (prop ".")
             ("def" prop "=" prop "."))
       (terms (id) (terms "," terms))
       (prop ("all" id ":" prop)
             ("let" prop "=" prop "in" prop)
             ("ex" id ":" prop)
             (prop "<=>" prop)
             (prop "=>" prop)
             (prop "&&" prop)
             (prop "||" prop)
             ("(" prop ")")
             ("(" terms ")")
             (id)))
     '((assoc ","))
     '((assoc ":") (assoc "in") (assoc "<=>") (assoc "=>") (assoc "||") (assoc "&&")))
    )))

(defun tql-rules (kind token)
  "SMIE rules.
KIND: SMIE kind
TOKEN: SMIE token"
  (pcase (cons kind token)
    (`(:after . "in") 0)
    (`(:elem . basic) 2)
    (`(:elem . args) 0)))

(setq tql-mode-syntax-table
  "Syntax table."
      (let ((table (make-syntax-table)))
        (modify-syntax-entry ?# "<" table)
        (modify-syntax-entry ?\n ">" table)
        table))

(defun tql-init ()
  "Initialize TQL major mode."
  (set-syntax-table tql-mode-syntax-table)
  (smie-setup tql-grammar 'tql-rules)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-end) "")
  (use-local-map tql-mode-map))

(provide 'tql-mode)

;; Local Variables:
;; lexical-binding: t

;;; tql-mode.el ends here
