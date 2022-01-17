set PATH /home/ryan/.local/bin $PATH
set PATH /home/ryan/bin $PATH
set PATH /home/ryan/.cargo/bin $PATH
set PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH
set PATH $HOME/go/bin $PATH

# Set Default Editor to Emacs
# set VISUAL 'emacs -nw --eval "(add-hook \'emacs-startup-hook #\'sh-mode)"'
set VISUAL nvim

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

# ..............................................................................
# * Notetaking Stuff ...........................................................
# ..............................................................................


# ** Searching .................................................................
function _private_search
    set notes_dir $argv

    nvim (
        sk -m -i -c "note_taking search -d "$notes_dir"  {}"        \
            --bind pgup:preview-page-up,pgdn:preview-page-down      \
            --preview "bat --style grid --color=always              \
                            --terminal-width 80 $notes_dir/{+}      \
                            --italic-text=always                    \
                            --decorations=always"                |  \
        sed "s#^#$notes_dir/#"
    )
end

# *** Search New notes
function ns
    _private_search ~/Notes
end

# *** Search ALL notes
# I symlinked ~/Notes under ~/Sync/Notes to catch it in this (excludes dokuwiki though)
function nS
    _private_search ~/Sync/Notes
end

# ** Finding ......................................................................
## I could have used `note_taking fzf` but skim and bat is prettier
function _private_finding
    fd '\.org$|\.md$' $argv |
        sk --ansi -m -c 'rg -l -t markdown -t org -t txt --ignore-case "{}"' \
            --preview "bat --style snip {} 2> /dev/null --color=always" \
            --bind 'ctrl-f:interactive,pgup:preview-page-up,pgdn:preview-page-down'
end

# *** Find main notes
function nf --description 'Find Notes'
    set _notes (_private_finding ~/Notes) \
        && nvim $_notes
end

# *** Find ALL notes
function nF
    # Find the notes and open if not cancelled
    set _notes (_private_finding ~/Notes ~/Sync/Notes /srv/http/dokuwiki/) \
        && nvim $_notes
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
    paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro sudo paru -S $argv
end

# Open work Dispatcher
function wk --description 'Alias for work script' --wraps='workdispatch'
    emacsclient --create-frame ~/Agenda/todo.org ~/Agenda/projects.org & disown
end



# ## Make sure to reflink btrfs
# function cp --description 'use reflink auto for deduped in btrfs' --wraps='cp'
#   cp --reflink=auto $argv;
# end
