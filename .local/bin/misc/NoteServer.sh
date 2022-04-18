#!/bin/bash
# Don't forget to adjust the permissions with:
#chmod +x ~/somecrazyfolder/script1

# use spacemacs and:
  #Use C-c C-n and C-c C-x and C-c C-z and C-c C-( and sh-if and sh-for
  # There's also snippets, use =company-yasnippet=
    # LaTeX in Vim but Bash in emacs
        # Probably R in Rstudio (and some vim for math and maybe emacs for folding)


## Help Statement
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` -g will serve it globally on 192.168.0.134:8351"
  exit 0
echo "Hello World"
fi


## Program


### Description
# This will print 'Hello World' to the STDOUT.


if [ "$1" == "-g" ]; then
    cd /home/ryan/Dropbox/Notes/MD/notes
    python3 -m http.server 8351 --bind 192.168.0.134 
    exit 0
fi

### Code
cd /home/ryan/Dropbox/Notes/MD/notes
python3 -m http.server 8351  

exit 0


## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='

