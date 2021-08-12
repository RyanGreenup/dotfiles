#!/bin/bash
# Don't forget to adjust the permissions with:
#chmod +x ~/somecrazyfolder/script1

## Program


### Description
# This will edit whichever file has the corresponding clipboard string
# The idea is to copy complex text to the clipboard to open a Boostnote file in vim.

### Code
vim $(ag -l $(xclip -o -selection clipboard))



## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='

