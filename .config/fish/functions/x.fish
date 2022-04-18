# Defined in - @ line 1
function x --wraps='xclip -selection clipboard' --description 'alias x=xclip -selection clipboard'
  xclip -selection clipboard $argv;
end
