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
    /usr/bin/brave http:://home.eir http://flarum.eir http://wikijs.eir --new-window & disown
    /usr/bin/brave http://pixie:3877 --new-window & disown
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
    emacs ~/Agenda/clockreport.org --eval '(progn (find-file "~/Notes/slipbox/journals/months/2024-july.org") (split-window-horizontally) (other-window 1) (org-agenda-list nil "a") (other-window 1))' & disown
    # emacs --eval '(load-theme "doom-badger" t)'
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


