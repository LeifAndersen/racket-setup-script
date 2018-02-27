#lang racket

(require compiler/find-exe
         pkg
         pkg/lib
         racket/runtime-path)

(define-runtime-path git (find-executable-path "git"))

(define pkgs '("scribble"
               "typed-racket"
               "option-contract"
               "draw"
               "db"
               "html"
               "images"
               "gui"
               "drracket"
               "wxme"
               "syntax-color"
               "data"
               "parser-tools"
               "math"
               "sandbox-lib"
               "errortrace"
               "web-server"
               "string-constants"
               "redex"
               "readline"
               "slideshow"
               "xrepl"
               "lazy"
               "macro-debugger"
               "htdp"
               "plai"
               "memoize"
               "realm"
               "plot"
               "swindle"
               "graph"
               "web-server"
               "rackunit"
               "unix-socket"
               "snip"
               "pict"
               "pict-snip"
               "ppict"
               "icons"
               "disassemble"
               "handin"
               "profile"
               "optimization-coach"
               "games"
               "unstable"
               "benchmark"
               "plt-web"
               "pkg-index"
               "nanopass"
               "gregor"
               "distro-build"
               "reloadable"
;               "aws"
               "racket-lang-org"
;               "cKanren"
               "minikanren"
               "glob"
               "rfc6455"
               "parsack"
;               "generic-bind"
               "markdown"
               ;"zordoz"
;               "slideshow-pretty"
               "slideshow-latex"
               "slideshow-repl"
;               "prospect"
;               "prospect-gl"
               "raco-find-collection"
               "threading"
               "rackjure"
               "frog"
               "cow-repl"
;               "tzinfo"
;               "tzdata"
;               ;"pict3d"
               "opengl"
               "python"
;               ;"c"
               "c-utils"
               "c-defs"
               ;"charterm"
               "css-tools"
               "cover"
               "cover-coveralls"
               "doc-coverage"
               "dlm-read"
               "drracket-vim-tool"
               "feature-profile"
               "fulmar"
               "irc"
               "irc-client"
;               "racket-cheat"
;               "puresuri"
               "python-tokenizer"
               "quickcheck"
;               "superc"
               "sweet-exp"
               "portaudio"
               "rsound"
;               "syntax-lang"
               ;"remote-shell"
;               "script-plugin"
               "txexpr"
               "pollen"
;               "debug"
               "colon-kw"
;               "colon-match"
;               "sicp"
               "deferred"
               "define-match-spread-out"
               "defpat"
               "pfds"
               "while-loop"
               "control"
               "hygienic-quote-lang"
               "hygienic-reader-extension"
               ;"collections"
               "trivial"
               "pdf-read"
               "racket-poppler"
;               "datatype"
;               "portaudio"
               "point-free"
;               "adapton"
;               ;"github"
;               "github-api"
               "classicthesis-scribble"
               "rsvg"
;               "racketeer"
               "with-cache"
               "multimethod"
               "profj"
               "java-lexer"
               "r-lexer"
               "binary-class"
               "binary-class-mp3"
               "bitsyntax"
               ;"cur"
;               "sudo"
               "rosette"
               "webapi"
               "google"
               "request"
               "talk-typer"
               "gir"
               "fancy-app"
               "minikanren"
               "sdl"
               "data-red-black"
               "derp-3"
               "drdr"
               "ecmascript"
               ;"wart"
              ;"elf"
               "explorer"
               "exact-decimal-lang"
               ;"hamt"
               "midi-readwrite"
               "minipascal"
               ;"struct-update"
               "lens"
               "command-line-ext"
               "mutt"
               "turnstile"
               "doodle"
               "scratch"
               "reprovide-lang"
               ))
(define planet-pkgs '("jowalsh/code-coverage"
                      ;"dyoo/bf"
                      ;"neil/scribble-emacs"
                      ;"neil/csv:1:=7"
                      ))
(define git-pkgs '(;("sdl" "git@github.com:cosmez/racket-sdl.git" "racket-sdl/sdl")
                   ))

(parameterize ([current-directory (build-path (find-system-path 'home-dir) "rsrc")]
               [current-input-port (open-input-bytes #"")])
  (for ([i (in-list pkgs)])
    (cond [(hash-has-key? (installed-pkg-table) i)
           (match (hash-ref (installed-pkg-table) i)
             [(struct* pkg-info ([orig-pkg `(clone ,_ ,_)]))
              (pkg-update-command #:deps 'search-auto i)]
             [else
              (pkg-update-command #:deps 'search-auto #:multi-clone 'convert #:clone i i)])]
          [else
           (pkg-install-command #:deps 'search-auto #:multi-clone 'convert #:clone i i)]))
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
