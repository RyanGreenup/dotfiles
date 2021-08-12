# Defined in - @ line 1
function o2dw --wraps='xclip -selection clipboard -o  | pandoc -t dokuwiki -f org | xclip -selection clipboard' --description 'alias o2dw=xclip -selection clipboard -o  | pandoc -t dokuwiki -f org | xclip -selection clipboard'
  xclip -selection clipboard -o  | pandoc -t dokuwiki -f org | xclip -selection clipboard $argv;
end
