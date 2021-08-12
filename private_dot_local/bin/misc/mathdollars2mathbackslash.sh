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
    cleanMath "${@:-}"

}

## ** Helper Functions

## *** Set variables almost globally

cleanMath() {

    dep="sd"
    command -v "${dep}" >/dev/null 2>&1 || { echo >&2 "I require "${dep}" but it's not installed. see github.com/chmln/sd  Aborting."; exit 1; }


    if [[ "${1:-}" == "" ]]; then
        echo "Error: No File Provided as input"
        return 1
    elif [[ -f "${1}" ]]; then
        cat "${1}" | sd '\$\$([^$]+)\$\$' ' \[ $1 \]' | sd '\$([^$\s][^$]*)\$' '\($1\)'
    else
        echo "Error: File Not Found, exiting"
        return 1
    fi


}
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
#            --opt3) echo "option 3"
#                ;;
            --*) echo "bad option "${1}" in "${script_name}""
                ;;
#            *) echo -e "argument \e[1;35m${1}\e[0m has no definition."
#                ;;
        esac
        shift
    done
}

## *** Print Help

Help () {
        # Display Help
        echo "Replace Math between dollars with \( \) and \[ \]"
        echo
        echo "Syntax: ${script_name} <file>"
        echo "options:"
        # echo "g     Print the GPL license notification."
        echo "h     Print this Help."
        # echo "v     Verbose mode."
        # echo "V     Print software version and exit."

    echo
    echo -e "    \e[3m\e[1m    Warning \e[0m "
    echo -e "    \e[1;31m -------------------------\e[0m "
    echo

    echo -e " Inline math must not have whitespace  directly after the beginning or"
    echo -e " Directly before the end of the $ delimiter"
    echo -e " The sed should still work but don't hold your breath on it working reliably."
    echo

        exit 0
}

## * Call Main Function
main "${@:-}"
