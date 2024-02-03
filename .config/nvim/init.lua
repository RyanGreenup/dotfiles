require('plugins/packer')

require('autocommands') -- Put these before lsp

require('lualine').setup { tabline = {} }

-- LSP

require('plugins/neodev')          -- Must precede lsp setup
-- require('plugins/lsp+omnifunc') -- Only enable one of these
require('plugins/lsp+cmp')

require('plugins/vimtex')
require('plugins/markdown-preview')

require('plugins/iron')
-- require('plugins/dap')
require('plugins/org-mode')
require('plugins/which-key')


-- Load keymap last
require('settings')
require('keymaps')



