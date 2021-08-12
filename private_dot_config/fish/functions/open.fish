# Defined in - @ line 1
function open --wraps=xdg-open --description 'alias open=xdg-open'
  xdg-open  $argv;
end
