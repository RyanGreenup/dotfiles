require('plugins/packer') -- lua/plugins/packer.lua
require('settings')
require('keymaps')
require('lualine').setup { tabline = {} }

-- LSP
-- require('plugins/lsp+omnifunc') -- Only enable one of these
require('plugins/lsp+cmp')

require('plugins/nvim-tree')
require('plugins/vimtex')
require('plugins/markdown-preview')

require('plugins/iron')
require('plugins/indent-blankline')
require('plugins/org-mode')



-- https://www.reddit.com/r/neovim/comments/mdqz41/nvimwhichkeysetuplua_plugin_wrapping_whichkey_to/
-- https://github.com/Olical/aniseed


-- https://github.com/glacambre/firenvim/issues/426
