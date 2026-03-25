# Options
setopt AUTO_CD
setopt NO_BEEP
setopt CORRECT
setopt EXTENDED_GLOB

# Deduplicate PATH entries
typeset -U path

# PATH
path+=(
    /usr/local/bin
    /usr/lib/rstudio
    /var/lib/flatpak/exports/bin
    $HOME/.local/bin
    $HOME/bin
    $HOME/.cargo/bin
    $HOME/.gem/ruby/2.7.0/bin
    $HOME/.local/share/gem/ruby/3.0.0/bin
    $HOME/.local/share/gem/ruby/3.2.0/bin
    $HOME/go/bin
    $HOME/.local/share/nvim/mason/bin
    $HOME/Applications/AppImages/bin
    $HOME/.local/share/JetBrains/Toolbox/scripts
)

# Nix
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    export QT_XCB_GL_INTEGRATION=none  # needed for nix Qt apps
fi

# Keep /usr/bin at the front (nix prepends itself)
path=(/usr/bin $path)

# Plugins (regenerate when .zshrc changes)
if [[ ! -f ~/.config/zr.zsh ]] || [[ ~/.zshrc -nt ~/.config/zr.zsh ]]; then
    zr \
        geometry-zsh/geometry \
        jedahan/geometry-hydrate \
        jedahan/geometry-todo \
        junegunn/fzf.git/shell/key-bindings.zsh \
        sorin-ionescu/prezto.git/modules/history/init.zsh \
        zsh-users/zsh-autosuggestions \
        zdharma-continuum/fast-syntax-highlighting \
        molovo/tipz \
        ael-code/zsh-colored-man-pages \
        momo-lab/zsh-abbrev-alias \
        jedahan/alacritty-completions \
        zpm-zsh/ssh \
        > ~/.config/zr.zsh
fi
source ~/.config/zr.zsh

# Atuin
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# OS-specific config
if grep -qP '^NAME=(Gentoo|Funtoo)' /etc/os-release 2>/dev/null; then
    export PKG_CONFIG_PATH="/usr/lib64/pkgconfig/"
fi

# CUDA (host only, skip in containers)
if [[ ! -f /run/.containerenv ]] && [[ -d /usr/local/cuda ]]; then
    export CUDA_HOME=/usr/local/cuda
    path+=(/usr/local/cuda/bin)
fi

# API keys
load_key() {
    local key_file="$HOME/.local/keys/$1"
    [[ -f "$key_file" ]] && export "$2"="$(< "$key_file")"
}

load_key openai.key           OPENAI_API_KEY
load_key anthropic.key        ANTHROPIC_API_KEY
load_key deepseek.key         DEEPSEEK_API_KEY
load_key typesense.key        TYPESENSE_API_KEY
load_key sambanova.key        SAMBANOVA_API_KEY
load_key clickhouse.key       CLICKHOUSE_PASSWORD
load_key clickhouse-mariadb.key CLICKHOUSE_PASSWORD_MYSQL
load_key lambda-ai.key        LAMBDA_API_KEY
load_key forgejo.key          TUTORIAL_TOKEN
load_key context7.key         CONTEXT7_API_KEY
load_key gemini.key           GEMINI_API_KEY
load_key cerebras.key         CEREBRAS_API_KEY

# Fabric
if [[ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]]; then
    . "$HOME/.config/fabric/fabric-bootstrap.inc"
fi

# Use fish as interactive shell (keep at bottom)
if [[ -x /bin/fish && -z "$IN_NIX_SHELL" ]]; then
    SHELL=/bin/fish exec fish
fi
