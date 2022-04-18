# Defined via `source`
function c --wraps='set target (fd | fzf) && cd $target || cd (dirname $target)' --description 'alias c=set target (fd | fzf) && cd $target || cd (dirname $target)'
  set target (fd | fzf) && cd $target || cd (dirname $target) $argv; 
  echo -e '\n executed:\n\n set target (fd | fzf) && cd $target || cd (dirname $target) \n'  
end
