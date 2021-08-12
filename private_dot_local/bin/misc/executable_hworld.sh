#!/bin/bash
set -euo pipefail
# Don't forget to adjust the permissions with:
#chmod +x ~/somecrazyfolder/script1

# use spacemacs and:
  #Use C-c C-n and C-c C-x and C-c C-z and C-c C-( and sh-if and sh-for
  # There's also snippets, use =company-yasnippet=
    # LaTeX in Vim but Bash in emacs
        # Probably R in Rstudio (and some vim for math and maybe emacs for folding)

# You may need to change shells with:
#
#   grep tecmint /etc/passwd
#   chsh --shell /bin/sh tecmint
#   grep tecmint /etc/passwd

#

## Help Statement
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` WRITE HELP HERE"
  exit 0
elif [[ "$1" == *-m* ]]; then
    echo "the option had the letter m somewhere"
    if [[ "$2" == "" ]]; then
        echo "The second argument was null"
    else
        style=$2
        echo "The second argument was" $2
    fi
    exit 0
else
    echo "the option was neither -h nor did it contain -m in it"
    exit 0
fi

## Program


### Description
# This will print 'Hello World' to the STDOUT.

### Code
echo "Hello World"


exit 0


## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='
