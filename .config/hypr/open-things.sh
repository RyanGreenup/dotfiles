#!/bin/sh

# TODO change the 'where' depending on what OS I'm on. Cause ugh.

notes_write() {
    # I don't know why nvim won't open
    cd ~/Notes/slipbox && Neovide.AppImage index.md & disown
    # TODO probably not Ryan approved
    # Open the most recent journal
    cd ~/Notes/slipbox
    LATEST_JOURNAL="$(ls -t journals/*.md | head -n1)"
    Neovide.AppImage "$LATEST_JOURNAL" & disown
    # Obsidian.AppImage & disown
    /usr/bin/obsidian & disown
}

notes_read() {
    /usr/bin/brave https://home.vidar/ --new-window & disown
    /usr/bin/firefox -P webApp & disown
}

# agenda() {
#     emacs ~/Agenda/clockreport.org --eval '(progn (find-file "~/Agenda/clockreport.org") (split-window-horizontally) (other-window 1) (org-agenda-list nil "a") (other-window 1))' & disown
#     # emacs --eval '(load-theme "doom-badger" t)'
# }

# agenda() {
#     emacs --eval '(progn (open-latest-journal-page) (split-window-horizontally) (other-window 1) (org-agenda-list nil "a") (other-window 1))' & disown
#     # emacs --eval '(load-theme "doom-badger" t)'
# }

# TODO decide!
agenda() {
    # emacs ~/Agenda/clockreport.org --eval '(progn (find-file "~/Notes/slipbox/journals/months/2024-july.org") (split-window-horizontally) (other-window 1) (org-agenda-list nil "a") (other-window 1))' & disown
    # emacs --eval '(load-theme "doom-badger" t)'
    emacs --eval '(org-agenda-list nil "a")' & disown
}

messages() {
    # TODO I forgot which ones I'm using
    # org.signal.Signal & disown
    /usr/bin/signal-desktop & disown
    /usr/bin/element-desktop & disown
    # org.ferdium.Ferdium & disown
    /usr/bin/ferdium
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


