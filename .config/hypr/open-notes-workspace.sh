#!/bin/sh

notes() {
    firefox-bin --profile ~/.mozilla/firefox/webapp http://localhost:3818/linux/too-many-open-files & disown
    $HOME/Applications/AppImages/Obsidian-1.5.8.AppImage --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --disable-gpu & disown
}

agenda() {
    /usr/bin/distrobox-enter  -n text_editors -- /bin/sh -l -c  emacs  & disown
    # --eval '(org-agenda nil "a")'
}

options() {
    cat "${0}" | grep ')$' | tr -d ')' | tr -d '"' | tr -d '*'
}

case "$1" in
    "notes")
        notes
        ;;
    "agenda")
        agenda
        ;;
    *)
        echo "Invalid choice. Please enter either:"
        options
        ;;
esac


