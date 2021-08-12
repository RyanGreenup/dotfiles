# Defined in - @ line 1
function h --wraps='history | head -n 30 | tac | x' --description 'alias h=history | head -n 30 | tac | x'
  history | head -n 30 | tac | x $argv;
end
