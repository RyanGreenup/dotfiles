#!/usr/bin/sh

# editor='emacsclient --create-frame'
editor='gnvim'

# sd calls:
#  1. remove #anchor-tags
#  2. extract id
#  3. replace ':' with '/'
#  4. prend the file path
file="$(echo "${QUTE_URL}" |\
     sd '.*id=(.*)#.*$' 'id=$1' |\
     sd '.*id=(.*)' '$1.txt' |\
     sd ':' '/' | tr -d '\n' |\
     sd '^' "$HOME/Notes/dokuwiki/data/pages/")"

${editor} "${file}"
