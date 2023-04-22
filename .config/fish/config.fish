# Set PATH
set PATH $HOME/.local/bin           $PATH
set PATH $HOME/bin                  $PATH
set PATH $HOME/.cargo/bin           $PATH
set PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH
set PATH $HOME/go/bin               $PATH
set PATH $PATH $HOME/.local/share/gem/ruby/3.0.0/bin

# Add AppImages
set PATH $PATH $HOME/Applications/AppImages/bin/

# Add Flatpak
set PATH $PATH /var/lib/flatpak/exports/bin/
set XDG_DATA_DIRS $XDG_DATA_DIRS:/var/lib/flatpak/exports/share/

# Set Default Editor to Emacs
# set VISUAL 'emacs -nw --eval "(add-hook \'emacs-startup-hook #\'sh-mode)"'
export VISUAL=nvim
export EDITOR=nvim

export LIBTORCH=/opt/libtorch
export LD_LIBRARY_PATH="$LIBTORCH"/lib:"$LD_LIBRARY_PATH"

function v --wraps=nvim --description 'alias v=nvim'
  nvim $argv;
end

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

# Man pages
function vman
    man $argv[1] | nvim -MR +"set filetype=man" -
end

function k!
    ps -aux | grep $argv[1] | awk '{print $2}' | xargs kill
end

function open_dokuwiki_clipboard
   set file \
       (xclip -sel clip -o |\
          awk -F '/' '{print $NF}' |\
          awk -F '=' '{print $NF}' |\
          sed 's#:#/#' |\
          sed 's#$#.txt#' |\
          sed 's#^#~/Notes/dokuwiki/data/pages/#')
    emacsclient -c $file
end

# Toggle Alacritty theme
function tt
    # If the colors: line is found, use sed to change it to dark or light
    grep  'colors: \*light' ~/.config/alacritty/alacritty.yml && sed -i  's!colors:\ \*light!colors: *dark!' ~/.config/alacritty/alacritty.yml && return 0
    grep  'colors: \*dark'  ~/.config/alacritty/alacritty.yml && sed -i  's!colors:\ \*dark!colors: *light!' ~/.config/alacritty/alacritty.yml && return 0
end

if status is-interactive
    broot --print-shell-function fish | source
end

if status is-interactive
    zoxide init fish | source
end

if status is-interactive
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source

    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end

function lfcd
    set tmp (mktemp)
    lf -last-dir-path=$tmp $argv
    if test -f "$tmp"
        set dir (cat $tmp)
        rm -f $tmp
        if test -d "$dir"
            if test "$dir" != (pwd)
                cd $dir
            end
        end
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
   # use ls -t to sort by time (default is modification time)
    ls -t (fd -t f '\.org$|\.md$|\.txt$' $argv) |
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
function get_os
    cat /etc/os-release | grep -e '^ID=' | cut -d '=' -f 2 | sed 's/"//g'
end

function void_query_packages
    xbps-query -Rs '' |\
        rg -o '[\w-]+-'  |\
        sed 's!-$!!'     |\
        fzf --multi --preview \
            'xbps-query -S {} || echo No Info Available'
end

function pz --description 'Fuzzy Find to preview and install packages'
    switch (get_os)
    case 'void'
        if set packages (void_query_packages)
            doas xbps-install $packages
        end
    case 'arch'
        pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S $argv
    case "*"
        echo "Operating System $os is not configured"
    end
end

# All Available Packages
function pZ --description 'Fuzzy Find to preview and install with pacman'
    paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S --noconfirm --needed $argv
end

# Open work Dispatcher
function wk --description 'Alias for work script' --wraps='workdispatch'
    emacsclient --create-frame ~/Agenda/todo.org ~/Agenda/projects.org & disown
end

set dotfiles_dir $HOME/.local/share/dotfiles
function gd
    git --work-tree $HOME --git-dir $dotfiles_dir $argv
end
function gdui
    gitui --polling -w $HOME -d $dotfiles_dir
end

# Create keybindings
function fish_user_key_bindings
	fzf_key_bindings
end
bind \en '
    set tmp (mktemp)       && \
    lf -last-dir-path=$tmp && \
    z (cat $tmp)
    rm $tmp
    commandline -f repaint'

bind \co '
    set tmp (mktemp)    && \
    broot --outcmd $tmp && \
    z (
        sed "s/^cd //g" < $tmp | sed "s/\"//g")
    rm $tmp
    commandline -f repaint'
