#!/bin/sh
 set -o nounset  # Abort on unbound variable

    CONF="$HOME/.config"
    SHARE="$HOME/.local/share"
NVIM_CONF="${CONF}/nvim"
NVIM_SHARE="${SHARE}/nvim"

main() {
    check_syms || (help; exit 1)

    profile="$(echo ~/.config/nvim_* | tr ' ' '\n' | fzf)"
    profile="$(basename "${profile}")"


    rm "${NVIM_SHARE}"
    rm "${NVIM_CONF}"

    # echo "The profile is ${profile}"
    ln -s  "${CONF}"/"${profile}"   "${NVIM_CONF}" || (echo "ERROR: Unable to symlink under ${CONF}, exiting."; exit 1)
    ln -s "${SHARE}"/"${profile}" "${NVIM_SHARE}"  || (echo "ERROR: Unable to symlink under ${CONF}, exiting."; exit 1)
}

help() {
    echo ""
    echo "symlink a directory of the form nvim_desc to nvim for the dirs:"
    printf "  * %s"   "${NVIM_CONF}"
    echo ""
    printf "  * %s"   "${NVIM_SHARE}"
    echo ""
    echo ""
    exit
}

test_sym() {
    [ "$(realpath "${1}")" = "${NVIM_CONF}" ] && ( echo "${NVIM_CONF}" is not a symlink, exiting.; help;  exit 1 )
}

check_syms() {
    test_sym "${NVIM_CONF}"
    test_sym "${NVIM_SHARE}"
}



main
