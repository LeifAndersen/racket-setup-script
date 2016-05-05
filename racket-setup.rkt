#lang racket

(require compiler/find-exe
         pkg
         pkg/lib
         racket/runtime-path)

(define-runtime-path git (find-executable-path "git"))

(define pkgs '(;"scribble"
;               "typed-racket"
;               "gui"
;               "drracket"
;               "redex"
;               "readline"
;               "compiler"
;               "slideshow"
;               "xrepl"
               "plot"
               "pict"
;               "profile"
;               "optimization-coach"
;               "games"
               "unstable"
               "benchmark"
;               "plt-web"
;               "pkg-index"
;               "distro-build"
;               "reloadable"
;               "aws"
;               "racket-lang-org"
;               "cKanren"
;               "minikanren"
;               "glob"
               "rfc6455"
               "parsack"
;               "generic-bind"
               "markdown"
;               "zordoz"
;               "slideshow-pretty"
;               "slideshow-latex"
               "slideshow-repl"
;               "prospect"
;               "prospect-gl"
               "raco-find-collection"
;               "threading"
               "rackjure"
               "frog"
;               "cow-repl"
;               "tzinfo"
;               "tzdata"
               "gregor"
;               ;"pict3d"
               "opengl"
;               "python"
;               ;"c"
;               "c-utils"
;               "c-defs"
;               "css-tools"
               "cover"
               "cover-coveralls"
               "doc-coverage"
               "dlm-read"
               "drracket-vim-tool"
               "feature-profile"
;               "fulmar"
;               "irc"
;               "irc-client"
;               "racket-cheat"
;               "puresuri"
;               "python-tokenizer"
;               "quickcheck"
;               "superc"
               "sweet-exp"
               "rsound"
;               "syntax-lang"
;               "remote-shell"
;               "script-plugin"
               "txexpr"
               "pollen"
;               "debug"
               "colon-kw"
;               "colon-match"
;               "sicp"
;               "pfds"
;               "while-loop"
;               "control"
;               "hygenic-quote-lang"
               "collections"
;               "trivial"
;               "pdf-read"
               "racket-poppler"
;               "datatype"
;               "portaudio"
               "point-free"
;               "adapton"
;               ;"github"
;               "github-api"
               "acmsmall"
               "classicthesis-scribble"
;               "rsvg"
;               "racketeer"
               "multimethod"
               "profj"
               "java-lexer"
               "r-lexer"
               ))
(define planet-pkgs '(;"jowalsh/code-coverage"
                      ;"dyoo/bf"
                      ;"neil/scribble-emacs"
                      ;"neil/csv:1:=7"
                      ))
(define git-pkgs '(("rosette" "https://github.com/emina/rosette" "rosette/rosette")
                  ("sdl" "git@github.com:cosmez/racket-sdl.git" "racket-sdl/sdl")
                   ))

(parameterize ([current-directory "/Users/leif/rsrc"])
  (for ([i (in-list pkgs)])
    (cond [(hash-has-key? (installed-pkg-table) i)
           (match (hash-ref (installed-pkg-table) i)
             [(struct* pkg-info ([orig-pkg `(clone ,_ ,_)]))
              (pkg-update-command #:deps 'search-auto i)]
             [else
              (pkg-update-command #:deps 'search-auto #:multi-clone 'convert #:clone #t i)])]
          [else
           (pkg-install-command #:deps 'search-auto #:multi-clone 'convert #:clone #t i)]))
  (for ([i (in-list planet-pkgs)])
    (system* (find-exe) "-e" (format "(require (planet ~a))" i)))
  (for ([i (in-list git-pkgs)])
    (match i
      [`(,name ,repo ,subfolder)
       (cond
         [(hash-has-key? (installed-pkg-table) name)
          (unless (non-empty-string?
                   (with-output-to-string
                     (λ ()
                       (system* git "status" "--porcelain"))))
            (system* git "pull" repo)
            (system* (find-exe) "-l" "raco" "setup"))]
         [else
          (system* git "clone" repo)
          (parameterize ([current-directory subfolder])
            (pkg-install-command #:name name))])])))
