# Defined in - @ line 1
function xs --wraps=echo\ -e\ \"\\n\\n\ \ maim\ --select\ \|\ xclip\ -selection\ clipboard\ -target\ image/png\\n\\n\"\;\ \ maim\ --select\ \|\ xclip\ -selection\ clipboard\ -target\ image/png --description alias\ xs=echo\ -e\ \"\\n\\n\ \ maim\ --select\ \|\ xclip\ -selection\ clipboard\ -target\ image/png\\n\\n\"\;\ \ maim\ --select\ \|\ xclip\ -selection\ clipboard\ -target\ image/png
  echo -e "\n\n  maim --select | xclip -selection clipboard -target image/png\n\n";  maim --select | xclip -selection clipboard -target image/png $argv;
end
