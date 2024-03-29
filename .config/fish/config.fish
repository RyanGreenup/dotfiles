# Set PATH
set PATH /usr/local/bin/ $PATH
set PATH $HOME/.local/bin $PATH
set PATH $HOME/bin $PATH
set PATH $HOME/.cargo/bin $PATH
set PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH
set PATH $HOME/.local/share/gem/ruby/3.2.0/bin $PATH
set PATH $HOME/go/bin $PATH
set PATH $PATH $HOME/.local/share/gem/ruby/3.0.0/bin
set PATH $PATH /usr/lib/rstudio

# Add AppImages
set PATH $PATH $HOME/Applications/AppImages/bin/

# Add Flatpak
set PATH $PATH /var/lib/flatpak/exports/bin/
set XDG_DATA_DIRS $XDG_DATA_DIRS:/var/lib/flatpak/exports/share/

# Add Flatpak
set PATH $PATH $HOME/.nix-profile/bin/

set PATH $HOME/.local/share/nvim/mason/bin/ $PATH

export QT_XCB_GL_INTEGRATION=none
# <https://github.com/NixOS/nixpkgs/issues/169630>

# Set Default Editor to Emacs
# set VISUAL 'emacs -nw --eval "(add-hook \'emacs-startup-hook #\'sh-mode)"'
export VISUAL=nvim
export EDITOR=nvim

export SVDIR=$HOME/.local/service

export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/"

if test -d /opt/libtorch
    export LIBTORCH=/opt/libtorch
    export LD_LIBRARY_PATH="$LIBTORCH"/lib:"$LD_LIBRARY_PATH"
end

function v --wraps=nvim --description 'alias v=nvim'
    nvim $argv
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
function xp
    if test -z $WAYLAND_DISPLAY
        xclip -selection clipboard -out
    else
        wl-paste
    end
end

function x
    if test -z $WAYLAND_DISPLAY
        xclip -selection clipboard
    else
        wl-copy
    end
end


function bn
    $HOME/.local/bin/os.utils.bulk_rename.py
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
        curl v2.wttr.in >/tmp/weather.txt && set have_weather true
        curl wttr.in >>/tmp/weather.txt && set have_weather true
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

function dokuwiki_nvim
    $HOME/.local/bin/dokuwiki/edit_dokuwiki_files_in_nvim.py
end

# Toggle Alacritty theme
function tt
    # If the colors: line is found, use sed to change it to dark or light
    grep 'colors: \*light' ~/.config/alacritty/alacritty.yml && sed -i 's!colors:\ \*light!colors: *dark!' ~/.config/alacritty/alacritty.yml && return 0
    grep 'colors: \*dark' ~/.config/alacritty/alacritty.yml && sed -i 's!colors:\ \*dark!colors: *light!' ~/.config/alacritty/alacritty.yml && return 0
end

function ws
    ~/.local/bin/mediawiki_firefox_search.sh $argv
end

function nsw
    ~/.local/bin/mediawikisearch.bash
end

function zj
    zellij a main || zellij --session main
end

if status is-interactive
    if command -v broot 1>/dev/null 2>&1
        broot --print-shell-function fish | source
    end
end

if status is-interactive
    if command -v zoxide 1>/dev/null 2>&1
        zoxide init fish | source
    end
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
set __notes_dir $HOME/Notes/slipbox
set __notes_old $HOME/Sync/Notes
set __notes_dw /srv/http/dokuwiki/data
set __note_taking_dirs $__notes_dir $__notes_old $__notes_dw

# git
function __try_run
    command -v $argv[1] >/dev/null 2>&1 && $argv[1]
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

    sk -m -i -c "note_taking search -d "$notes_dir"  {}" \
        --bind pgup:preview-page-up,pgdn:preview-page-down \
        --preview "bat --style grid --color=always              \
                            --terminal-width 80 $notes_dir/{+}      \
                            --italic-text=always                    \
                            --decorations=always" | sed "s#^#$notes_dir/#"
end


# *** Search New notes
function ns
    _private_open (_private_search $__notes_dir)
end




function nl
    $HOME/.config/fish/note_aliases.py --nl --notes_dir $__notes_dir
end

function nsem
    note_taking sem -d $__notes_dir
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

# function nn
#     note_taking new -d "$__notes_dir"
# end

function nno
    echo "Enter note Title:"
    set title (read)
    echo $notes_dir
    set file (readlink -f "$__notes_dir/pages/$title.org") # use readlink to clean path
    echo "# $title" >>$file
    emacs $file
end

function nnm
    echo "Enter note Title:"
    set title (read)
    echo $notes_dir
    set file (readlink -f "$__notes_dir/pages/$title.md") # use readlink to clean path
    echo "# $title" >>$file
    $EDITOR $file
end

function nn_old
    # note_taking new -d "$__notes_dir"

    # TODO wrap this into the go program
    # The difference is the use of directories rather than namespaces
    set file (mktemp)
    echo "Type the title of the Note:"
    cd ~/Notes/slipbox
    set dir (fd -t d | fzf || echo ".")
    nvim $file
    set title (tr -d '\n' < $file)
    set title (echo $title | tr -d '/' )
    set filename (echo $title | tr '[:upper:]' '[:lower:]' | sed -e 's#\.#-#g'  -e 's# #-#g' -e 's#$#.md#')
    set filename (echo $dir/$filename)
    if test -f $filename
        nvim $filename
    else
        echo $title | sed 's!^!# !' >>$HOME/Notes/slipbox/$filename
    end
    nvim $filename
    rm $file
end

function nn
    # set root (fd '\.md$' ~/Notes/slipbox/ | rev | cut -d '.' -f 3- | rev | sort -u | sed "s#$HOME/Notes/slipbox/##" | fzf)
    ~/.local/bin/notes.new.py
end

# ..............................................................................
# * Package Management Stuff....................................................
# ..............................................................................

# Packages in Repository
function get_os
    cat /etc/os-release | grep -e '^ID=' | cut -d '=' -f 2 | sed 's/"//g'
end

function void_query_packages
    xbps-query -Rs '' | rg -o '[\w-]+-' | sed 's!-$!!' | fzf --multi --preview \
        'xbps-query -S {} || echo No Info Available'
end

function arch_pz
    pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S $argv
end

function pz --description 'Fuzzy Find to preview and install packages'
    switch (get_os)
        case void
            if set packages (void_query_packages)
                doas xbps-install $packages
            end
        case arch
            arch_pz
        case endeavouros
            arch_pz
        case "*"
            echo "Operating System $os is not configured"
    end
end

# All Available Packages
function pZ --description 'Fuzzy Find to preview and install with pacman'
    yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S --noconfirm --needed $argv
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
    gitui -w $HOME -d $dotfiles_dir
end

function start_podman_containers
    if status is-interactive
        if command -v podman-compose >/dev/null 2>&1
            for yaml in (ls ~/Applications/Containers/user/vidar/**/docker-compose.yml)
                # get the container name
                set name (basename (dirname $yaml))
                # Not necessary but this means I can use the same snippet to restart
                podman-compose -f $yaml down
                # Start the containers
                podman-compose -f $yaml up -d \
                    && printf '\n\n SUCCESS -- %s \n\n' $name \
                    || printf '\n\n FAILURE  -- %s \n\n' $name
            end
        else
            echo "podman-compose is missing, try:"
            echo ""
            echo "    ```"
            echo "    pipx install podman-compose"
            echo "    ```"
        end
    end
end

if status is-interactive
    if command -v starship >/dev/null 2>&1
        starship init fish --print-full-init | source
    end
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

bind \ex '
    echo dash
    dashboard'

bind \co '
    set tmp (mktemp)    && \
    broot --outcmd $tmp && \
    z (
        sed "s/^cd //g" < $tmp | sed "s/\"//g")
    rm $tmp
    commandline -f repaint'





if status is-interactive
    if command -v hoard 1>/dev/null 2>&1
        hoard shell-config -s fish | source
    end
end
