# Defined in - @ line 1
function myema --wraps='emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el' --wraps='emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el & disown' --wraps='emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/index.org  & disown' --wraps='emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/index.org  & disown' --description 'alias myema=emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/index.org  & disown'
  emacs -Q -l /home/ryan/DotFiles/EmacsPersonal/init.el ~/Notes/Org/index.org  & disown $argv;
end
