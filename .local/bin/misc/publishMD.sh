#!/usr/bin/env bash
# set -euo pipefail
#
#This is symlinked to /usr/local/bin/ so that:
#
#    + It can be run as root
#    + Remain in the path
#

## Define Server and Notes Location
Server="/srv/http"
Notes=/home/ryan/Notes # Location of mkdocs.yml
MKDOCS="/home/ryan/.local/bin/mkdocs"
TEMP="$(mktemp -d)"

## Change Directory
cd "${Notes}/"
rm -r "${Notes}/MD/00TagMatch"

## Build the Documentation
##
##
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0`
             # -d or --dirty for dirty build, defaults to --clean"
  exit 0
elif [[ "$1" == *-d* || "$1" == *--dirty* ]]; then
 "${MKDOCS}" build --dirty --site-dir "${TEMP}/MD/"
 sudo mv "${TEMP}/MD/" "${Server}/MD"
exit 0
else
 "${MKDOCS}" build --clean --site-dir "${TEMP}/MD/"
 sudo mv "${TEMP}/MD/" "${Server}/MD"
exit 0
fi
## TODO Clean, Dirty
# "${MKDOCS}" build --dirty --site-dir $Server/MD/


## cd /home/ryan/Notes/
## "${MKDOCS}" build
##  [ -d "/home/ryan/Public/html/MD" ] && sudo rm -r /home/ryan/Public/html/MD
##  [ -d "./site" ] && sudo mv site /home/ryan/Public/html/MD/
