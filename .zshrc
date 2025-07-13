# Created by newuser for 5.9


# Path
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
.local/bin \
bin \
.cargo/bin \
.gem/ruby/2.7.0/bin/ \
.local/share/gem/ruby/3.2.0/bin \
go/bin \
.local/share/gem/ruby/3.0.0/bin \
.local/share/nvim/mason/bin/ \
Applications/AppImages/bin/




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
if [ $(command -v atuin) ]; then
    eval "$(atuin init zsh)"
fi


# Toolbox
# Added by Toolbox App
__jetpack_toolbox_directory="$HOME/.local/share/JetBrains/Toolbox/scripts"

if [ -d "${__jetpack_toolbox_directory}" ]; then
    export PATH="$PATH:${__jetpack_toolbox_directory}"
fi


os_name=$(grep -oP '(?<=^NAME=).*(?=)' /etc/os-release)
if [ "$os_name" = "Gentoo" ] || [ "$os_name" = "Funtoo" ]; then
  export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/"
fi


# PATH
# Nix
# added by Nix installer
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/nix.sh
fi
export QT_XCB_GL_INTEGRATION=none # Needed for nix QT apps (breaks anki)

# Get usr bin at the front
# NOTE where the fuck is nix getting added???
PATH="/usr/bin:${PATH}"

key_file=$HOME/.local/openai.key
if [ -f "${key_file}" ]; then
    read -r OPENAI_API_KEY < "${key_file}"
    export OPENAI_API_KEY
fi

key_file=$HOME/.local/keys/anthropic.key
if [ -f "${key_file}" ]; then
    read -r ANTHROPIC_API_KEY < "${key_file}"
    export ANTHROPIC_API_KEY
fi


key_file=$HOME/.local/keys/deepseek.key
if [ -f "${key_file}" ]; then
    read -r DEEPSEEK_API_KEY  < "${key_file}"
    export  DEEPSEEK_API_KEY
fi

key_file=$HOME/.local/keys/typesense.key
if [ -f "${key_file}" ]; then
    read -r TYPESENSE_API_KEY  < "${key_file}"
    export  TYPESENSE_API_KEY
fi

key_file=$HOME/.local/keys/sambanova.key
if [ -f "${key_file}" ]; then
    read -r SAMBANOVA_API_KEY  < "${key_file}"
    export  SAMBANOVA_API_KEY
fi

key_file=$HOME/.local/keys/clickhouse
if [ -f "${key_file}" ]; then
    read -r CLICKHOUSE_PASSWORD  < "${key_file}"
    export  CLICKHOUSE_PASSWORD
fi


key_file=$HOME/.local/keys/lambda_ai.key
if [ -f "${key_file}" ]; then
    read -r LAMBDA_API_KEY  < "${key_file}"
    export  LAMBDA_API_KEY
fi

# Use fish in place of bash/zsh
# keep this line at the bottom of ~/.bashrc / ~/.zshrc
  [ -x /bin/fish ] && [ -z "$IN_NIX_SHELL" ] && SHELL=/bin/fish exec fish
# [ -x /bin/elvish ] && [ -z "$IN_NIX_SHELL" ] && SHELL=/bin/elvish elvish
if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then . "$HOME/.config/fabric/fabric-bootstrap.inc"; fi
