#!/usr/bin/env bash
set -euo pipefail

echo -e "Please Enter Search Term\n"
read search
search_fix="$(echo "${search}" | sed 's/\ /+/g')"
echo "${search_fix}"
echo -e "Searching Dokuwiki"
url="http://localhost:8888/doku.php?q=${search_fix}&do=search"
# Chromium seems to work better with the bootstrap theme.
chromium "${url}" & disown
