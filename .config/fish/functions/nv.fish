# Automatically updates Neovim before Starting
function nv --wraps='nvim --headless -c "lua vim.pack.update()" -c "quitall"; and nvim' --description 'alias nv=nvim --headless -c "lua vim.pack.update()" -c "quitall"; and nvim'
    nvim --headless -c "lua vim.pack.update()" -c quitall; and nvim $argv
end
