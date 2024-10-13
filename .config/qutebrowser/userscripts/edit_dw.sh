#!/bin/sh

# editor='emacsclient --create-frame'
# editor='alacritty -e nvim'
editor='neovide'

# sd calls:
#  1. remove #anchor-tags
#  2. extract id
#  3. replace ':' with '/'
#  4. prend the file path
# DOKU_BASE="$HOME/Notes/dokuwiki/data/pages"
value=${MY_DOKU_BASE:$HOME/Notes/dokuwiki/config/dokuwiki/data/pages}

DOKU_BASE="$HOME/Applications/Docker/dokuwiki/config/dokuwiki/data/pages/"

# notify-send "Opening ${QUTE_URL}"
file="$(echo "${QUTE_URL}" |\
     sd '.*id=(.*)#.*$' 'id=$1' |\
     sd '.*id=(.*)' '$1.txt' |\
     sd ':' '/' | tr -d '\n' |\
     sd '^' "${DOKU_BASE}")"

${editor} "${file}"
