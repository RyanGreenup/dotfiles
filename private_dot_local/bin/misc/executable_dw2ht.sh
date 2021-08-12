#!/usr/bin/env bash

CLIP_IN () { xclip -selection clipboard ; }
CLIP_OUT () {  xclip -selection clipboard -o ; }

if [[ "${1}" == "-h" ]]; then
    CLIP_OUT | \
    pandoc -f dokuwiki -t html | \
    pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax -s | \
    CLIP_IN
elif [[ "${1}" == -o ]]; then
    CLIP_OUT | \
    pandoc -f dokuwiki -t html | \
    pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax -s | \
    pandoc -f html -t org | \
    CLIP_IN
elif [[ "${1}" == "-m" ]]; then
    CLIP_OUT | \
    pandoc -f dokuwiki -t html | \
    pandoc -f html+tex_math_dollars+tex_math_single_backslash -t markdown --atx-headers -s |\
    CLIP_IN
elif [[ "${1}" == "-p" ]]; then
    # TODO Merge this with Cadmus and do something like this:
    # pandoc -s --self-contained "%" --listings --toc -H ~/Dropbox/profiles/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown

    FILE="$(mktemp)"

echo '
\RequirePackage{listings}
\RequirePackage{listings}
%Listings----------------------------------------


\definecolor{dkgreen}{rgb}{0,0.6,0}
\definecolor{gray}{rgb}{0.5,0.5,0.5}
\definecolor{mauve}{rgb}{0.58,0,0.82}
\lstset{
  frame=tb,
  frame=leftline,
  framesep=15pt,
  language=Java,
  aboveskip=15pt,
  belowskip=20pt,
  showstringspaces=false,
  columns=flexible,
  basicstyle={\small\ttfamily},
  numbers=none,
%  backgroundcolor=\color{Snow2},
  numberstyle=\tiny\color{gray},
  keywordstyle=\color{blue},
  commentstyle=\color{dkgreen},
  stringstyle=\color{mauve},
  breaklines=true,
  breakatwhitespace=true,
  tabsize=3,
  xleftmargin=1in,
}
' > "${FILE}.sty"


    CLIP_OUT | \
        pandoc -f dokuwiki -t html | \
        pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax -s | \
        pandoc -f html+tex_math_dollars+tex_math_single_backslash --pdf-engine=xelatex -H "${FILE}.sty" --listings -o "${FILE}.pdf"
    xdg-open "${FILE}.pdf" & disown
else
    echo -e "First argument should be -h/-o/-p/-m"
    echo -e "\t for html, org, pdf, markdown respectively"
fi

