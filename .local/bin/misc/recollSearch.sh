#!/bin/bash

recollq -b "$1 mime:text/plain" | cut -c 8- | fzf --preview "highlight -O ansi -l {} 2> /dev/null" | xargs atom
