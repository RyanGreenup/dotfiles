# Defined in - @ line 1
function nfo --wraps='orgNoteFind.sh ~/Notes/Org | xargs ema' --description 'alias nfo=orgNoteFind.sh ~/Notes/Org | xargs ema'
  orgNoteFind.sh ~/Notes/Org | xargs ema $argv;
end
