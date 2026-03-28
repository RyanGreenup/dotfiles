--------------------------------------------------------------------------------
-- Markdown---------------------------------------------------------------------
--------------------------------------------------------------------------------

local md_in_buffer_preview = {
  'MeanderingProgrammer/render-markdown.nvim',
  name = 'render-markdown',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = { 'markdown', 'mdx' },
  opts = {
    start_enabled = false,
    heading = {
      enabled = true,
      icons = { '◉ ', '○ ', '✸ ', '✿ ', '◆ ', '◇ ' },
      position = 'inline',
      width = 'full',
      backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
      },
    },
    bullet = {
      enabled = true,
      icons = { '●', '○', '◆', '◇' },
    },
    checkbox = {
      enabled = true,
      unchecked = { icon = '☐ ' },
      checked = { icon = '☑ ' },
      custom = {
        in_progress = { raw = '[-]', rendered = '◐ ', highlight = 'RenderMarkdownWarn' },
      },
    },
    code = {
      enabled = true,
      sign = false,
      width = 'full',
      border = 'thin',
    },
  },
}

local md_browser_preview = {
  'brianhuster/live-preview.nvim',
  cmd = 'LivePreview',
  ft = { 'markdown' },
  opts = {
    sync_scroll = true,
  },
}

local femaco = {
  'gen4438/nvim-FeMaco.lua',
  opts = {
    -- Preserve indentation for code blocks (e.g., in markdown lists)
    normalize_indent = function(base_filetype)
      -- Return false for markdown to preserve original indentation
      return true
    end,
    ensure_newline = function(base_filetype)
      -- Ensure proper newlines for markdown code blocks
      -- return base_filetype == 'markdown'
      -- Nah always add a newline
      return true
    end
  }
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
local firenvim = { 'glacambre/firenvim', build = ":call firenvim#install(0)" }

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
  org_mode,
  md_in_buffer_preview,
  md_browser_preview,
  femaco,
  dokuwiki,
  firenvim,
  vimtex,
}
