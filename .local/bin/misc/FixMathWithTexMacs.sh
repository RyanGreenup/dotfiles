#! /usr/bin/env bash
    IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
    readonly script_name=$(basename "${0}")
             script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    readonly script_dir=$(realpath "${script_dir}""/""${script_name}" | xargs dirname)
DIR="$(mktemp -d)"
FILE="Clipboard_math"
cd "${DIR}"

main() {
    openHelp "${@}"        # Open Help
    checkDep || exit 1        # Check Dependencies
    setClipboard    # MacOS or Linux?
    saveClip        # Save the clipboard to a temp file
    ConvertClip     # Open the clipboard with TexMacs
    rm -r "${DIR}"  # Clear Temp Files
}

saveClip () {
    echo "$(CLIP_OUT)" > "${FILE}".tex
}

ConvertClip () {
    texmacs "${FILE}".tex
    # Use pandoc to strip header arguments, i.e.
    # make it not --standalone.
    cat "${FILE}".tex | pandoc -f latex -t latex | CLIP_IN
}

setClipboard () {

case "$(uname -s)" in

    Darwin)
        CLIP_IN () { pbcopy ; }
        CLIP_OUT () {  pbpaste ; }
        xdg-open () {  open "%{@}" ; }
     ;;

    Linux|GNU|*BSD|SunOS)
        ## "$XDG_SESSION_TYPE" not always defined
        if [[ "$( loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type | rg 'wayland' )" ]]; then
            CLIP_IN () { wl-copy ; }
            CLIP_OUT () {  wl-paste ; }
        else
            CLIP_IN () { xclip -selection clipboard ; }
            CLIP_OUT () {  xclip -selection clipboard -o ; }
        fi
     ;;

   CYGWIN*|MINGW32*|MSYS*|MINGW*)
            CLIP_IN () { xclip -selection clipboard ; }
            CLIP_OUT () {  xclip -selection clipboard -o ; }
     ;;

   # Add here more strings to compare
   # See correspondence table at the bottom of this answer

   *)
       echo "Could not Detect OS, if you're not on Mac/Linux, file a bug please"
       echo "Applying Linux Defaults"
        CLIP_IN () { xclip -selection clipboard ; }
        CLIP_OUT () {  xclip -selection clipboard -o ; }
     ;;
esac


}

checkDep () {
    DEP="pandoc" ; command -v "${DEP}"  >/dev/null 2>&1 || { echo -e >&2 "I require ${DEP} but it's not installed"; return 1; }
    DEP="texmacs"; command -v "${DEP}"  >/dev/null 2>&1 || { echo -e >&2 "I require ${DEP} but it's not installed"; return 1; }
}

openHelp () {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        echo ""
        echo "Usage: ${script_name}"
        echo ""
        echo  "Copy some math into the clipboard"
        echo  "This will open whatever is in the clipboard in TexMacs"
        echo  "Edit the math in texmacs"
        echo  "Save (answer yes to any data conversion prompt with Alt+y)"
        echo  "The new math should be in the clipboard"
        echo ""
        exit 0
    fi
}

# * Call the Main Function
main "${@}"
