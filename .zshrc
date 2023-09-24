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

# PATH
# Nix
# added by Nix installer
if [ -e /home/ryan/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/ryan/.nix-profile/etc/profile.d/nix.sh
fi
export QT_XCB_GL_INTEGRATION=none # Needed for nix QT apps (breaks anki)

# Toolbox
# Added by Toolbox App
__jetpack_toolbox_directory="/home/ryan/.local/share/JetBrains/Toolbox/scripts"

if [ -d "${__jetpack_toolbox_directory}" ]; then
    export PATH="$PATH:${__jetpack_toolbox_directory}"
fi


PATH="${PATH}:/usr/local/bin/"
PATH="${PATH}:$HOME/.local/bin"
PATH="${PATH}:$HOME/bin"
PATH="${PATH}:$HOME/.cargo/bin"
PATH="${PATH}:$HOME/.gem/ruby/2.7.0/bin/"
PATH="${PATH}:$HOME/.local/share/gem/ruby/3.2.0/bin"
PATH="${PATH}:$HOME/go/bin"
PATH="${PATH}:$HOME/.local/share/gem/ruby/3.0.0/bin"
PATH="${PATH}:/usr/lib/rstudio"

PATH="${PATH}:$HOME/.local/share/nvim/mason/bin/"

# Add AppImages
PATH="${PATH}:$HOME/Applications/AppImages/bin/"

# Add Flatpak
PATH="${PATH}:/var/lib/flatpak/exports/bin/"
XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share/"

# Add Flatpak
PATH="${PATH}:$HOME/.nix-profile/bin/"


