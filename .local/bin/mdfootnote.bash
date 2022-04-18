#!/bin/bash
time="$(date +%s)"
url="$(xclip -selection clipboard -o)"

echo -e "[^${time}]\n\n[^${time}]:\n    ${url}"
