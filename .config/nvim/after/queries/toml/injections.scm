; extends

; Mise TOML: inject language into run = '...' strings
; Multiline with shebang using env (e.g. #!/usr/bin/env python)
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#match? @injection.language "^['\"]{3}\n*#!(/\\w+)+/env\\s+\\w+")
  (#gsub! @injection.language "^.*#!/.*/env%s+([^%s]+).*" "%1")
  (#offset! @injection.content 0 3 0 -3)
)

; Multiline with direct shebang (e.g. #!/bin/bash)
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#match? @injection.language "^['\"]{3}\n*#!(/\\w+)+\s*\n")
  (#gsub! @injection.language "^.*#!/.*/([^/%s]+).*" "%1")
  (#offset! @injection.content 0 3 0 -3)
)

; Multiline without shebang — default to bash
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#match? @injection.content "^['\"]{3}\n*.*")
  (#not-match? @injection.content "^['\"]{3}\n*#!")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "bash")
)

; Single-line — default to bash
(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#not-match? @injection.content "^['\"]{3}")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "bash")
)
