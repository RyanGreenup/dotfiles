#!/bin/bash
## /bin/makeMarkdown.sh

INPUT_FORMAT=$(pandoc --list-output-formats | fzf)
OUTPUT_FORMAT="markdown_github+tex_math_dollars --atx-headers"
x="xclip -selection clipboard"

$x -o | pandoc -f $INPUT_FORMAT -t $OUTPUT_FORMAT | $x
