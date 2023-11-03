#!/bin/sh

# Check for yad (yad is a zenity fork)
command -v yad >/dev/null 2>&1 || { echo >&2 "I require yad but it's not installed.  it can be installed with emerge gnome-extra/yad"; exit 1; }

# get the user query
query="$(yad --form --field="Query" --columns=1)" || exit 1

# Search the query
firefox -P webapp "http://localhost:8076/index.php?title=Special%3ASearch&search=${query}"


## See Also
# ~/.local/bin/mediawikisearch.bash
