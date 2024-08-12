vim.g.mapleader = " "

if vim.g.vscode then
  -- require('config/packer')
  require('config/lazy_vscode')
  require('settings')
  require('keymaps')
else
  require('config.lazy')
  require('autocommands') -- Put these before lsp
  require('utils')
  -- Load settings later because themes may not be available
  -- TODO consider how to load themes iff available
  require('settings')
  -- Load keymap last
  require('keymaps')
end
