#!/bin/sh

# Get the URL
url="${QUTE_URL}"

# Change the url to have a /e in it
from="http://localhost:8926/"
to="${from}/e/"
url="$(sed -e "s|${from}|${to}|" <<< "${url}")"

# Open the URL by writing to the named pipe
echo "open -t ${url}" >> "${QUTE_FIFO}"
