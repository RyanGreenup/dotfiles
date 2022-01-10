require('plugins/packer')
require('settings')
require('keymaps')
require('lualine').setup{ tabline={} }

-- LSP
-- require('plugins/lsp+omnifunc') -- Only enable one of these
require('plugins/lsp+cmp')

require('plugins/nvim-tree')
require('plugins/vimtex')
require('plugins/markdown-preview')

require('plugins/iron')
require('plugins/indent-blankline')
require('plugins/org-mode')

