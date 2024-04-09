-- require('plugins/packer')
require('plugins/lazy')

require('autocommands') -- Put these before lsp

-- require('lualine').setup { tabline = {} }

-- -- LSP
require('plugins/neodev')          -- Must precede lsp setup
-- require('plugins/lsp+omnifunc') -- Only enable one of these
require('plugins/lsp+cmp')
require('plugins/snippy')
require('plugins/vimtex')
require('plugins/markdown-preview')

require('plugins/iron')
require('plugins/slime')

-- require('plugins/dap')
require('plugins/org-mode')
require('plugins/which-key')


-- -- Load keymap last
require('settings')
require('keymaps')








-- /home/ryan/.tabby-client/agent/config.toml
vim.g.tabby_trigger_mode = 'manual'
vim.g.tabby_keybinding_accept = '<Tab>'
vim.g.tabby_keybinding_trigger_or_dismiss = '<C-\\>'
