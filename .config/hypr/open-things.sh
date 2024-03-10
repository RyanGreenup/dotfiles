#!/bin/sh

notes() {
    firefox-bin --profile ~/.mozilla/firefox/webapp http://localhost:3818/ & disown
    ## $HOME/Applications/AppImages/Obsidian-1.5.8.AppImage --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --disable-gpu & disown
    ## flatpak run md.obsidian.Obsidian & disown
    Obsidian.AppImage & disown
}

agenda() {
    emacs --eval '(org-agenda nil "a")' --eval "(load-theme 'doom-badger t)"
    # /usr/bin/distrobox-enter  -n text_editors -- /bin/sh -l -c  emacs  & disown
    # --eval '(org-agenda nil "a")'
}

messages() {
    ## flatpak run org.signal.Signal & disown
    ## flatpak run im.riot.Riot & disown
    ## element-desktop & disown
    /usr/bin/distrobox-enter  -n containerized_apps-signal-desktop -- /bin/sh -l -c  /opt/Signal/signal-desktop   --no-sandbox & disown
    /usr/bin/distrobox-enter  -n containerized_apps-signal-desktop -- /bin/sh -l -c  /opt/Element/element-desktop              & disown
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
    "messages")
        messages
        ;;
    *)
        echo "Invalid choice. Please enter either:"
        options
        ;;
esac


