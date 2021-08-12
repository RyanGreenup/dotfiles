# Defined in - @ line 1
function nf --wraps='cadmus note find' --description 'alias nf=cadmus note find'
  cadmus note find $argv;
end
