# Defined in - @ line 0
function emtodo --wraps='emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/todo.org /home/ryan/DotFiles/EmacsPersonal/init.el  ~/Notes/Org/index.org' --description 'alias emtodo=emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/todo.org /home/ryan/DotFiles/EmacsPersonal/init.el  ~/Notes/Org/index.org'
  emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/todo.org /home/ryan/DotFiles/EmacsPersonal/init.el  ~/Notes/Org/index.org $argv & disown;
end
