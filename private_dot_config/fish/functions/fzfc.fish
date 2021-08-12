# Defined in - @ line 1
function fzfc --wraps='fzf --preview cat  | xargs realpath | xclip -selection clipboard' --description 'alias fzfc=fzf --preview cat  | xargs realpath | xclip -selection clipboard'
  fzf --preview cat  | xargs realpath | xclip -selection clipboard $argv;
end
