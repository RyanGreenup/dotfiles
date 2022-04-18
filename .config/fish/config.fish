set PATH /home/ryan/.local/bin $PATH
set PATH /home/ryan/bin $PATH
set PATH /home/ryan/.cargo/bin $PATH
set PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH
set PATH $HOME/go/bin $PATH

# Set Default Editor to Emacs
# set VISUAL 'emacs -nw --eval "(add-hook \'emacs-startup-hook #\'sh-mode)"'
set VISUAL nvim
set EDITOR nvim
# set EDITOR emacsclient -nw  # This isn't bad, still a little slower than nvim though

# ..............................................................................
# * Better Coreutils / Built-ins................................................
# ..............................................................................
# Defined in - @ line 1
function f --wraps='cd ; exa -RGL 3' --description 'alias f=cd; exa -RGL 3'
    cd $argv
    exa -TL 2
    exa
end

function l --wraps='cd ; exa -RGL 3' --description 'alias f=cd; exa -RGL 3'
    cd $argv
    exa -TL 2
    exa
end


## Better LS
function ls! --wraps='ls -ultrah' --description 'alias ls!=ls -ultrah'
    ls -ultrah $argv
end


## Easier Xclip
function x --wraps='xclip -selection clipboard' --description 'Alias for xclip'
    xclip -selection clipboard $argv
end

## Easy weather
function wtr
    # TODO put a test of age in here
    if test -f /tmp/weather.txt
        set have_weather true
    else
        set have_weather false
    end


    if $have_weather
        bat /tmp/weather.txt
    else
        curl v2.wttr.in > /tmp/weather.txt && set have_weather true
        curl wttr.in >> /tmp/weather.txt && set have_weather true
    end

    if ! $have_weather
        echo "Unable to download weather"
    end
end


# ..............................................................................
# * Notetaking Stuff ...........................................................
# ..............................................................................
set __agenda_dir $HOME/Agenda
set __notes_dir $HOME/Notes
set __notes_old $HOME/Sync/Notes
set __notes_dw  /srv/http/dokuwiki/data
set __note_taking_dirs $__notes_dir $__notes_old $__notes_dw

# git
function __try_run
    command -v $argv[1] > /dev/null 2>&1 && $argv[1]
end

function __git_helper
    __try_run gitui || lazygit
end

function gn
    cd $__notes_dir && __git_helper
end

function gt
    cd $__agenda_dir && __git_helper
end

# open non empty arguments in EDITOR
function _private_open
  if [ ! (count $argv) -eq 0 ]
      $EDITOR $argv
  end
end


# ** Searching .................................................................
function _private_search
    set notes_dir $argv
    cd $notes_dir

        sk -m -i -c "note_taking search -d "$notes_dir"  {}"        \
            --bind pgup:preview-page-up,pgdn:preview-page-down      \
            --preview "bat --style grid --color=always              \
                            --terminal-width 80 $notes_dir/{+}      \
                            --italic-text=always                    \
                            --decorations=always"                |  \
        sed "s#^#$notes_dir/#"
end


# *** Search New notes
function ns
    _private_open (_private_search $__notes_dir)
end

# *** Search ALL notes
# I symlinked ~/Notes under ~/Sync/Notes to catch it in this (excludes dokuwiki though)
function nso
    _private_open (_private_search $__notes_old)
end

function nsd # Dokuwiki
    _private_open (_private_search $__notes_dw)
end

# *** Reindex notes

function nR
  for dir in $__note_taking_dirs
    echo $dir
    note_taking reindex -d $dir
  end
end

function nr
    note_taking reindex -d $__notes_dir
end




# ** Finding ......................................................................
## I could have used `note_taking fzf` but skim and bat is prettier
function _private_finding
    fd '\.org$|\.md$|\.txt$' $argv |
        sk --ansi -m -c 'rg -l -t markdown -t org -t txt --ignore-case "{}"' \
            --preview "bat --style snip {} 2> /dev/null --color=always" \
            --bind 'ctrl-f:interactive,pgup:preview-page-up,pgdn:preview-page-down'
end

# *** Find main notes
function nf --description 'Find Notes'
    _private_open (_private_finding $__notes_dir)
end

# *** Find ALL notes
function nF
    # Find the notes and open if not cancelled
    _private_open (_private_finding $__note_taking_dirs)
end

function nfm
  ~/.local/bin/mediawikisearch.bash
end

function nn
    note_taking new -d "$__notes_dir"
end

function nno
    echo "Enter note Title:"
    set title (read)
    echo $notes_dir
    set file (readlink -f "$__notes_dir/pages/$title.org") # use readlink to clean path
    echo "# $title" >> $file
    emacs $file
end

function nnm
    echo "Enter note Title:"
    set title (read)
    echo $notes_dir
    set file (readlink -f "$__notes_dir/pages/$title.md") # use readlink to clean path
    echo "# $title" >> $file
    $EDITOR $file
end


# ..............................................................................
# * Package Management Stuff....................................................
# ..............................................................................

# Packages in Repository
function pz --description 'Fuzzy Find to preview and install with pacman'
    pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S $argv
end

# All Available Packages
function pZ --description 'Fuzzy Find to preview and install with pacman'
    paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S --noconfirm --needed $argv
end

# Open work Dispatcher
function wk --description 'Alias for work script' --wraps='workdispatch'
    emacsclient --create-frame ~/Agenda/todo.org ~/Agenda/projects.org & disown
end

# Man pages
function vman
    man $argv[1] | nvim -MR +"set filetype=man" -
end


# ............................................................
# Niceties
# ............................................................
function kill_discord
    ps ax | grep discord | cut  -d ' ' -f 1 | xargs kill
end

# ## Make sure to reflink btrfs
# function cp --description 'use reflink auto for deduped in btrfs' --wraps='cp'
#   cp --reflink=auto $argv;
# end


set dotfiles_dir $HOME/.local/share/dotfiles
function gd
    git --work-tree $HOME --git-dir $dotfiles_dir $argv
end
function gdui
    gitui -w $HOME -d $dotfiles_dir
end