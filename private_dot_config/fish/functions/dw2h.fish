# Defined in - @ line 1
function dw2h --wraps='xclip -o -selection clipboard | pandoc -f dokuwiki -t html | pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax | xclip -selection clipboard' --description 'alias dw2h=xclip -o -selection clipboard | pandoc -f dokuwiki -t html | pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax | xclip -selection clipboard'
  xclip -o -selection clipboard | pandoc -f dokuwiki -t html | pandoc -f html+tex_math_dollars+tex_math_single_backslash -t html --mathjax | xclip -selection clipboard $argv;
end
