#!/usr/bin/sh

editor='emacsclient --create-frame'

file="$(echo "${QUTE_URL}" |\
     sd '.*id=(.*)' '$1.txt' |\
     sd ':' '/' | tr -d '\n' |\
     sd '^' "$HOME/Notes/dokuwiki/data/pages/")"

${editor} "${file}"
