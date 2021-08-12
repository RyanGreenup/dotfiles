# Defined in - @ line 1
function dw2o --wraps='xclip -selection clipboard | pandoc -f dokuwiki -t org | xclip -selection clipboard' --wraps='xclip -selection clipboard -o  | pandoc -f dokuwiki -t org | xclip -selection clipboard' --description 'alias dw2o=xclip -selection clipboard -o  | pandoc -f dokuwiki -t org | xclip -selection clipboard'
  xclip -selection clipboard -o  | pandoc -f dokuwiki -t org | xclip -selection clipboard $argv;
end
