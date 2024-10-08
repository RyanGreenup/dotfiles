--------------------------------------------------------------------------------
-- Markdown---------------------------------------------------------------------
--------------------------------------------------------------------------------

local md_preview = {
  "iamcco/markdown-preview.nvim",
  build = function() vim.fn["mkdp#util#install"]() end,
}

local md_in_buffer_preview = {
  'MeanderingProgrammer/markdown.nvim',
  name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    -- Configure whether Markdown should be rendered by default or not
    start_enabled = false
  }
}

local femaco = {
  'AckslD/nvim-FeMaco.lua',
  opts = {}
}

local table_mode = { 'dhruvasagar/vim-table-mode' }

--------------------------------------------------------------------------------
-- LaTeX -----------------------------------------------------------------------
--------------------------------------------------------------------------------
local vimtex = { 'lervag/vimtex' }

--------------------------------------------------------------------------------
-- Dokuwiki --------------------------------------------------------------------
--------------------------------------------------------------------------------
local dokuwiki = { 'nblock/vim-dokuwiki' }
local firenvim = { 'glacambre/firenvim', build = function() vim.fn['firenvim#install'](0) end }

--------------------------------------------------------------------------------
-- Org Mode---------------------------------------------------------------------
--------------------------------------------------------------------------------
local org_mode = {
  'nvim-orgmode/orgmode',
  config = function()
    require('config/org-mode')
  end,
}



return {
  table_mode,
  md_preview,
  org_mode,
  md_in_buffer_preview,
  femaco,
  dokuwiki,
  firenvim,
  vimtex,
}
