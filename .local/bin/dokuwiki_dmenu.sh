#!/bin/sh
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
# set -o pipefail # don't hide errors within pipes

BROWSER=qutebrowser
DW_DIR="$HOME/Notes/dokuwiki/data/pages"

cd "${DW_DIR}"
find ./ -name '*.txt' |\
    sed 's#^\./##'  |\
    sed 's#\.txt$##' |\
    sed 's#/#:#' |\
    dmenu -l 40 |\
    sed 's#^#http://localhost:8923/doku.php?id=#' |\
    xargs "${BROWSER}" 2>/dev/null &
#    xargs xdg-open 2>/dev/null &

## TODO how to select multiple

