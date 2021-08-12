#!/bin/bash
# Don't forget to adjust the permissions with:
#chmod +x ~/somecrazyfolder/script1

## Program


### Description
# will Export a website to MD/Org/LaTeX
# I took the code from:


### Choose what format to output in
 # LaTeX, # MD or # Org

 command -v recode >/dev/null 2>&1 || { echo >&2 "I require recode but it's not installed.  install with sudo apt recode (or pacman its in the repos), Aborting."; exit 1; }


if [ "$1" == "-h" ]; then
# Put's formated link in clipboard
  echo "
  Usage: `basename $0` <Format>

  This requires GNU recode and GNU wget, they're in the repos

     -m... Format Link for  Markdown........[Title](Link) 
     -o... Format Link for  Org.............[[Link][Title]]
     -l... Format Link for  LaTeX...........href{Link}{Title}
  "
  exit 0
fi


if [[ "$1" == *-m* ]]; then
	echo "Will Export as markdown Format (gfm not pandoc md cause bug)"
	type="gfm"
elif [[ "$1" == *-o* ]]; then
	echo "Will Export as Org Format"
	type="org"
elif [[ "$1" == *-l* ]]; then
	echo "Will Export as LaTeX Format"
	type="latex"
else
	echo "
	
	Please Specify an export Format

     m... Format Link for  Markdown........[Title](Link) 
     o... Format Link for  Org.............[[Link][Title]]
     l... Format Link for  LaTeX...........href{Link}{Title}
	"
	# Take the next single keystroke
        read -d'' -s -n1
	type=$REPLY

	# reassign type to the corresponding keystroke

	if [[ $type == m ]]; then
		echo ""
		echo "Will Export as markdown Format"
		type="gfm"
	elif [[ $type == o ]]; then
		echo ""
		echo "Will Export as Org Format"
		type="org"
	elif [[ $type == l ]]; then
		echo ""
		echo "Will Export as LaTeX Format"
		type="latex"
	else
		echo "
		   Correct input not detected.
		   either specify an argument or press the corresponding key,
		   refer to the help with `basename $0` -h.
		   "
		   exit 0

	    fi
    fi

# echo "The chosen format is $type" # To debug var assignment

### Take the link Variable
arglink=$(xclip -o -selection clipboard)

curl $arglink | pandoc -f HTML -t $type | xclip -selection clipboard

echo "Success, content in Clipboard"

exit 0

google.com


## vim:fdm=expr:fdl=0
## vim:fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'##*')-2)\:'='

exit 0
