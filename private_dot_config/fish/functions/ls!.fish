# Defined in - @ line 1
function ls! --wraps='ls -ultrah' --description 'alias ls!=ls -ultrah'
  ls -ultrah $argv;
end
