if vim.g.vscode then
  -- require('plugins/packer')
  require('plugins/lazy_vscode')
  require('settings')
  require('keymaps')
else
  -- require('plugins/packer')
  require('plugins/lazy')

  require('autocommands') -- Put these before lsp

  -- require('lualine').setup { tabline = {} }

  -- -- LSP
  require('plugins/neodev') -- Must precede lsp setup
  -- require('plugins/lsp+omnifunc') -- Only enable one of these
  require('plugins/lsp+cmp')
  require('plugins/snippy')
  require('plugins/vimtex')
  -- require('plugins/markdown-preview')

  require('plugins/iron')
  require('plugins/slime')

  -- require('plugins/dap')
  require('plugins/org-mode')
  require('plugins/which-key')

  -- Custom Utility Functions
  require('utils')


  -- -- Load keymap last
  require('settings')
  require('keymaps')
end

