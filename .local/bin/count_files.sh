#!/bin/sh

for dir in */; do                       # use globbing to list dirs
    cd "${dir}" 2>/dev/null || continue # if unable to cd, move on
    dir=${dir%*/}                       # Remove the trailing /
    count=$(find . -type f | wc -l)
    printf '%10d : %s\n' "${count}" "${dir}"
    cd ..
done | sort -nr

