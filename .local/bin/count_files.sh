#!/bin/sh

count_files() {
    for dir in */; do                       # use globbing to list dirs
        cd "${dir}" 2>/dev/null || continue # if unable to cd, move on
        dir=${dir%*/}                       # Remove the trailing /
        count=$(fd -u -t f| wc -l)
        # count=$(find . -type f | wc -l)
        printf '%10d : %s\n' "${count}" "${dir}"
        cd ..
    done | sort -nr
}

count_files_rec() {
    for dir in */; do                       # use globbing to list dirs
        d="${1}"
        cd "${dir}" 2>/dev/null || continue # if unable to cd, move on
        dir=${dir%*/}                       # Remove the trailing /
        count=$(find . -type f | wc -l)
        printf "%${1}d : %s\n" "${count}" "${dir}"
        count_files_rec $((d+4))
        cd ..
    done # | sort -nr
}

# count_files_rec 4
count_files
