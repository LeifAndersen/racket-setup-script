#lang s-exp framework/keybinding-lang

(require racket/system)

(define open (find-executable-path "open"))

(keybinding
 "d:s:i"
 (λ (editor event)
   (define name (send editor get-filename))
   (system* open "-a" "emacs" name)))
