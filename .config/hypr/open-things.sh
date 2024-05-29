#!/bin/sh

notes_write() {
    distrobox-enter  -n r -- /bin/sh -l -c  "/usr/share/codium/codium --disable-gpu --unity-launch ~/Notes/slipbox/ 1>/dev/null 2>&1" 1>/dev/null 2>&1 & disown
    neovide $HOME/Notes/slipbox/home.md
}

notes_read() {
    firefox-bin --profile ~/.mozilla/firefox/webapp --new-window http://localhost:8926 & disown
    $HOME/Applications/AppImages/Obsidian-1.5.8.AppImage --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --disable-gpu & disown
}

agenda() {
    /usr/bin/distrobox-enter  -n text_editors -- /bin/sh -l -c  emacs  & disown
    # --eval '(org-agenda nil "a")'
}

messages() {
    /usr/bin/distrobox-enter  -n containerized_apps-signal-desktop -- /bin/sh -l -c  /opt/Signal/signal-desktop   --no-sandbox & disown
    /usr/bin/distrobox-enter  -n containerized_apps-signal-desktop -- /bin/sh -l -c  /opt/Element/element-desktop              & disown
}

options() {
    cat "${0}" | grep ')$' | tr -d ')' | tr -d '"' | tr -d '*'
}

case "$1" in
    "notes_read")
        notes_read
        ;;
    "notes_write")
        notes_write
        ;;
    "agenda")
        agenda
        ;;
    "messages")
        messages
        ;;
    *)
        echo "Invalid choice. Please enter either:"
        options
        ;;
esac


