# Defined in - @ line 1
function rname --wraps='cat ~/Templates/names.txt | shuf -n 4' --description 'alias rname=cat ~/Templates/names.txt | shuf -n 4'
  cat ~/Templates/names.txt | shuf -n 4 $argv;
end
