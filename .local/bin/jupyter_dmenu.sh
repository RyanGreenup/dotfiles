#!/bin/sh
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
# set -o pipefail # don't hide errors within pipes

BROWSER=qutebrowser
DS_DIR="$HOME/Studies/DataSci/"

cd "${DS_DIR}"

notebook="$(fd '\.ipynb$' | dmenu -l 40)"
url="$(echo "${notebook}" | sed 's#\ #%20#g' | sed 's#^#https://localhost:8962/lab/tree/#')"
"${BROWSER}" "${url}"
