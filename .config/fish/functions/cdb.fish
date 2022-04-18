# Defined in - @ line 1
function cdb --wraps='cd (cat /tmp/bookmarks | uniq | fzf)' --description 'alias cdb=cd (cat /tmp/bookmarks | uniq | fzf)'
  cd (cat /tmp/bookmarks | uniq | fzf) $argv;
end
