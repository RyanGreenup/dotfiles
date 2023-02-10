require('plugins/packer')
require('lualine').setup { tabline = {} }

-- LSP
-- require('plugins/lsp+omnifunc') -- Only enable one of these
require('plugins/lsp+cmp')

require('plugins/vimtex')
require('plugins/markdown-preview')

require('plugins/iron')
-- require('plugins/dap')
require('plugins/indent-blankline')
require('plugins/org-mode')
require('plugins/which-key')


-- Load keymap last
require('settings')
require('keymaps')

