#! /usr/bin/env bash
#
## Author: Ryan Greenup <ryan.greenup@protonmail.com>

# * Shell Settings
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

## * Main Function
main() {
    setVars
    arguments  "${@:-}" # Pass empty string if arguments are empty
    URL="${1}?action=render"
    DIR="$(mktemp -d)"
    cd "$DIR"

    echo $(pwd)
    echo "${URL}"
    wget "${URL}" -O page.html
    pandoc -f html page.html -o page.md
    exit 0

}

## ** Helper Functions

## *** Set variables almost globally

setVars () {
    readonly script_name=$(basename "${0}")
    readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
}

## *** Interpret arguments
arguments () {
    while test $# -gt 0
    do
        case "$1" in
            --help) Help
                ;;
            -h) Help
                ;;
            --opt3) echo "option 3"
                ;;
            --opt4) echo "option 4"
                ;;
            --opt5) echo "option 5"
                ;;
            --opt6) echo "option 6"
                ;;
            --opt7) echo "option 7"
                ;;
            --opt8) echo "option 8"
                ;;
            --opt9) echo "option 9"
                ;;
            --opt10) echo "option 10"
                ;;
            --*) echo "bad option "${1}" in "${script_name}""
                ;;
            *) echo -e "argument \e[1;35m${1}\e[0m has no definition."
                ;;
        esac
        shift
    done
}

## *** Print Help

Help () {
        # Display Help
        echo "Add description of the script functions here."
        echo
        echo "Syntax: ${script_name} [-h|m]"
        echo
        echo "options:"
        echo "m     Return output in markdown only to STDOUT (not implemented)."
        echo "h     Print this Help."
        echo

#    echo
#    echo -e "    \e[3m\e[1m    NoteFind.sh \e[0m; Helpful Shell Scripts for Markdown Notes"
#    echo -e "    \e[1;31m -------------------------\e[0m "
#    echo
#
#    echo -e " \e[1;91m    \e[1m Binding \e[0m\e[0m \e[1;34m┊┊┊ \e[0m Description "
#    echo -e " ..............\e[1;34m┊┊┊\e[0m........................................... "
#    echo -e " \e[1;93m Ctrl - y \e[0m \e[1;34m   ┊┊┊ \e[0m Copy the Full Path to the Clipboard"
#    echo -e " \e[1;32m Ctrl - e \e[0m \e[1;34m   ┊┊┊ \e[0m Copy the Relative path to the clipboard"
#    echo -e " \e[1;33m Ctrl - q \e[0m \e[1;34m   ┊┊┊ \e[0m Toggle Searching with ripgrep"


        exit 0
}

## * Call Main Function
main "${@:-}"
