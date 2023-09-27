# Created by newuser for 5.9




# Plugins
# Generate new ~/.config/zr.zsh if it does not exist or if ~/.zshrc has been changed
if [[ ! -f ~/.config/zr.zsh ]] || [[ ~/.zshrc -nt ~/.config/zr.zsh ]]; then
  zr \
    frmendes/geometry \
    jedahan/geometry-hydrate \
    junegunn/fzf.git/shell/key-bindings.zsh \
     sorin-ionescu/prezto.git/modules/history/init.zsh \
    junegunn/fzf.git/shell/key-bindings.zsh \
    zsh-users/zsh-autosuggestions \
    zdharma/fast-syntax-highlighting \
    molovo/tipz \
    geometry-zsh/geometry \
    jedahan/geometry-hydrate \
    jedahan/geometry-todo \
    geometry-zsh/geometry \
    ael-code/zsh-colored-man-pages \
    momo-lab/zsh-abbrev-alias \
    jedahan/alacritty-completions \
    zpm-zsh/ssh \
    > ~/.config/zr.zsh
fi

source ~/.config/zr.zsh


# Atuin
eval "$(atuin init zsh)"


# Toolbox
# Added by Toolbox App
__jetpack_toolbox_directory="/home/ryan/.local/share/JetBrains/Toolbox/scripts"

if [ -d "${__jetpack_toolbox_directory}" ]; then
    export PATH="$PATH:${__jetpack_toolbox_directory}"
fi

append_path() {
    for i in $@; do
        PATH="${PATH}:${i}"
    done
}

append_home() {
    for i in $@; do
        PATH="${PATH}:${HOME}/${i}"
    done
}

append_path \
    /usr/local/bin \
    /usr/lib/rstudio \
    /var/lib/flatpak/exports/bin \

append_home \
$HOME/.local/bin \
$HOME/bin \
$HOME/.cargo/bin \
$HOME/.gem/ruby/2.7.0/bin/ \
$HOME/.local/share/gem/ruby/3.2.0/bin \
$HOME/go/bin \
$HOME/.local/share/gem/ruby/3.0.0/bin \
$HOME/.local/share/nvim/mason/bin/ \
$HOME/Applications/AppImages/bin/ \



# PATH
# Nix
# added by Nix installer
if [ -e /home/ryan/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/ryan/.nix-profile/etc/profile.d/nix.sh
fi
export QT_XCB_GL_INTEGRATION=none # Needed for nix QT apps (breaks anki)

# Get usr bin at the front
# NOTE where the fuck is nix getting added???
PATH="/usr/bin:${PATH}"


# Use fish in place of bash/zsh
# keep this line at the bottom of ~/.bashrc / ~/.zshrc
[ -x /bin/fish ] && [ -z "$IN_NIX_SHELL" ] && SHELL=/bin/fish exec fish
