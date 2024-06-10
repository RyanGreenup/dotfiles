#!/bin/sh

# Yeah babe; in POSIX shell you can't have empty functions like this
# See this <https://unix.stackexchange.com/questions/349632/can-a-function-in-sh-have-zero-statements>
# Basically you can use `:` to represent true or `pass` in python

notes_write() {
    # I don't know why nvim won't open
    cd ~/Notes/slipbox && Neovide.AppImage index.md & disown
    # TODO probably not Ryan approved
    # Open the most recent journal
    cd ~/Notes/slipbox
    LATEST_JOURNAL="$(ls -t journals/*.md | head -n1)"
    Neovide.AppImage "$LATEST_JOURNAL" & disown
    Obsidian.AppImage & disown
}

notes_read() {
    com.brave.Browser http:://home.eir http://flarum.eir http://wikijs.eir --new-window & disown
    com.brave.Browser http://pixie:3818 --new-window & disown
}

agenda() {
    emacs ~/Agenda/clockreport.org --eval '(progn (find-file "~/Agenda/clockreport.org") (split-window-horizontally) (other-window 1) (org-agenda-list nil "a") (other-window 1))' & disown
    # emacs --eval '(load-theme "doom-badger" t)'
}

messages() {
    # TODO I forgot which ones I'm using
    org.signal.Signal & disown
    /usr/bin/element-desktop & disown
    org.ferdium.Ferdium & disown
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


