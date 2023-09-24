#!/bin/sh

case "$1" in
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *.rar) unrar l "$1";;
    *.7z) 7z l "$1";;
    *.pdf) pdftotext "$1" -;;
    *.md) bat --color=always "$1" -;;
    *.markdown) bat --color=always "$1" -;;
    *.ansible*) bat --color=always --language=yaml "$1" -;;
    *) highlight -O ansi "$1";;
esac
