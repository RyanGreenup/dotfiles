#!/bin/bash
# git log | grep '^commit' | sed 's/^commit\ //' 
git log | grep '^commit' | sed 's/^commit\ //'  | \
    sk --ansi \
     --bind 'ctrl-f:interactive,pgup:preview-page-up,pgdn:preview-page-down'    \
     -m -c 'bat --color always | rg -l --ignore-case' \
    --preview 'git diff {}^! | bat --color always' \

    # TODO How to display commit date and line instead of ID
    # TODO How to implement grep?

