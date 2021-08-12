# Defined in - @ line 1
function f --wraps='cd ; exa -RGL 3' --description 'alias f=cd; exa -RGL 3'
  cd $argv ; exa -TL 2 ; exa ;
end
