# Automatically updates Neovim plugins with lazy.nvim before starting
function nv --wraps=nvim --description 'Update lazy.nvim plugins then start nvim'
    nvim --headless "+Lazy! sync" +qa; and nvim $argv
end
