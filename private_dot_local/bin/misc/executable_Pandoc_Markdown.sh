#!/bin/bash
## This will fail if resources are not found in the path,
## So, instead of taking the input from the clipboard,
## this should be executed from the directory of the
## Markdown file, Pointing to the markdown file.

## Steps
## 1. Change to the MD File Location using realpath
## 2. Execute essentially this scripts
## 3. Decide whether to put the output in tmp or in the same Location
  ## I think the same location tbh.
mdfile=$1
style=$2
echo $style

function main() {
  echo Creating HTML from $1
  parseArguments
  goToFile
  ConvertToHTML
  AddMathJaxandStyle
}

  function goToFile() {
    echo $mdfile
    cd $(realpath $mdfile | xargs dirname)
  }

  function ConvertToHTML() {
    pandoc -f markdown -t html -s --self-contained $mdfile -o /tmp/$mdfile.html
    cd /tmp
  }

  function AddMathJaxandStyle() {
    CreateStyle
    pandoc -f html -t html $mdfile.html -s -B $wrapped --mathjax -o $mdfile.html
    atom $mdfile.html
  }

  function CreateStyle() {
    wrapped=$(mktemp)
#    trap "rm $wrapped" EXIT

    echo "<style>" > $wrapped
    cat $style >> $wrapped
    echo "</style>" >> $wrapped
#    echo "<script type="text/javascript" async
#  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML">
  }

function parseArguments() {
  if [[ $style=="" ]]; then
    style=~/Templates/CSS/jekyllTypora.css
    echo "Using $style becuase nothing specified"
  else
    echo "Using $style as specified"
  fi
}
main
