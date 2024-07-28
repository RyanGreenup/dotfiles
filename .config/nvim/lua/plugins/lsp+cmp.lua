------------------------------------------------------------
-- Configure autocomplete with nvim-cmp
------------------------------------------------------------
-- This is copy and paste boiler plate because it was too complex to learn
--
-- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
-- https://github.com/hrsh7th/nvim-cmp/


-- Setup nvim-cmp.
local cmp = require 'cmp'

-- Specify how the border looks like
local my_border = {
  { '┌', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '┐', 'FloatBorder' },
  { '│', 'FloatBorder' },
  { '┘', 'FloatBorder' },
  { '─', 'FloatBorder' },
  { '└', 'FloatBorder' },
  { '│', 'FloatBorder' },
}

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    -- https://teddit.net/r/neovim/comments/u7nsje/nvimcmp_completion_issue_cn_gives_basic_completion/
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    {
      name = 'nvim_lsp',
      option = {
        markdown_oxide = {
          keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
        }
      }
    },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lsp' },
    { name = 'otter' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

--------------------------------------------------------------------------------
-- Mappings ---------------------------------------------------------[#mappings]
--------------------------------------------------------------------------------
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', '<F8>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    -- Enable Hints
    vim.g.inlay_hints_visible = true
    -- vim.lsp.inlay_hint(bufnr, true)
  else
    print("no inlay hints available")
  end
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<A-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'i', '<A-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wd',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

--------------------------------------------------------------------------------
-- road LSP --------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches

require 'lspconfig'.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}


local servers = {
  'bashls', 'clangd', 'clojure_lsp', 'cmake', 'csharp_ls', 'dartls', 'dockerls',
  'dotls', 'gopls', 'java_language_server', 'jsonls', 'lua_ls',
  'kotlin_language_server', 'nimls', 'quick_lint_js',
  'r_language_server', 'racket_langserver', 'rust_analyzer', 'texlab',
  'tsserver', 'stylelint_lsp', 'vala_ls', 'vls', 'zls', 'ols',
  'spectral', 'ansiblels', 'rome', 'jsonls', 'html', 'denols', 'marksman'
}

local python_servers = {
  'pylsp',         -- This is the main one, formatting requires it
  'ruff_lsp',      -- This is like pyright but with less Microsoft + black
  'basedpyright',  -- This performs type checking and static analysis
}

for _, s in pairs(python_servers) do
  table.insert(servers, s)
end


for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  if lsp == "basedpyright" then
    require('lspconfig')[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        basedpyright = {
          typeCheckingMode = "standard",
        },
      },
    })
  end
end

function markdown_oxide_on_attach(client, bufnr)
  on_attach(client, bufnr)
  -- refresh codelens on TextChanged and InsertLeave as well
  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach' }, {
    buffer = bufnr,
    callback = vim.lsp.codelens.refresh,
  })

  -- trigger codelens refresh
  vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
end

-- Markdown Oxide
-- This is too buggy to use
-- require("lspconfig").markdown_oxide.setup({
--   capabilities = capabilities, -- again, ensure that capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
--   on_attach = markdown_oxide_on_attach        -- configure your on attach config
-- })

-- sqlls requires a custom setup
-- https://github.com/LunarVim/LunarVim/discussions/4210
require("lspconfig")["sqlls"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "sql", "mysql", ".pgsql" },
  root_dir = function() return vim.loop.cwd() end,
  -- cmd = {"sql-language-server", "up", "--method", "stdio"};
})

-- For julia we have to use a custom setup for a sysimage
-- See https://github.com/fredrikekre/.dotfiles/blob/master/.julia/environments/nvim-lspconfig/Makefile
-- See ~/.julia/environments/nvim-lspconfig/Makefile
-- This is adapted from <https://github.com/fredrikekre/.dotfiles/blob/master/.config/nvim/init.vim>

require 'lspconfig'.julials.setup({
  on_new_config = function(new_config, _)
    local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
    new_config.cmd[1] = julia
  end,
  -- This just adds dirname(fname) as a fallback (see nvim-lspconfig#1768).
  root_dir = function(fname)
    local util = require 'lspconfig.util'
    return util.root_pattern 'Project.toml' (fname) or util.find_git_ancestor(fname) or
        util.path.dirname(fname)
  end,
  on_attach = on_attach,
  capabilities = capabilities,
})


------------------------------------------------------------
-- Some LSP styling [^1]
------------------------------------------------------------

-- Fix the hover in Pyright to remove HTML [^fn_tx40m2]
local clean_hover = function(_, result, ctx, config)
  if not (result and result.contents) then
    return vim.lsp.handlers.hover(_, result, ctx, config)
  end
  if type(result.contents) == "string" then
    local s = string.gsub(result.contents or "", "&nbsp;", " ")
    s = string.gsub(s, [[\\\n]], [[\n]])
    s = string.gsub(s, [[\\\_]], [[_]])
    s = string.gsub(s, [[\\*]], [[]])
    result.contents = s
    return vim.lsp.handlers.hover(_, result, ctx, config)
  else
    local s = string.gsub((result.contents or {}).value or "", "&nbsp;", " ")
    s = string.gsub(s, "\\\n", "\n")
    s = string.gsub(s, "\\_", "_")
    s = string.gsub(s, [[\\*]], [[]])
    result.contents.value = s
    return vim.lsp.handlers.hover(_, result, ctx, config)
  end
end

local lsp = vim.lsp
local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)
-- NOTE: the hover handler returns the bufnr,winnr so can be used for mappings
lsp.handlers['textDocument/hover'] = lsp.with(
-- Default hover function has &nbsp rubbish, see clean_hover func
-- lsp.handlers.hover,
  clean_hover,
  {
    border = my_border, -- could be 'single', 'double',
    -- 'shadow', 'rounded', 'solid'
    -- or `my_border` from above
    max_width = max_width,
    max_height = max_height
  }
)

lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, {
  border = 'shadow', -- could be 'single', 'double', 'shadow', 'rounded', 'solid'
  max_width = max_width,
  max_height = max_height,
})


vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '●', '▎', 'x'
    source = "always", -- Or "if_many"
  },
  float = {
    source = "always", -- Or "if_many"
  },
})
vim.cmd [[
  highlight! DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
  highlight! DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
  highlight! DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
  highlight! DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]


-- Nicer icons

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
local M = {}

M.icons = {
  Class       = "",
  Color       = "",
  Constant    = "",
  Constructor = "",
  Enum        = " ",
  EnumMember  = "",
  Field       = "",
  File        = "",
  Folder      = "",
  Function    = "",
  Interface   = "ﰮ",
  Keyword     = "",
  Method      = "ƒ",
  Module      = "",
  Property    = "",
  Snippet     = "﬌",
  Struct      = "",
  Text        = "",
  Unit        = "",
  Value       = "",
  Variable    = "",
}

function M.setup()
  local kinds = vim.lsp.protocol.CompletionItemKind
  for i, kind in ipairs(kinds) do
    kinds[i] = M.icons[kind] or kind
  end
end

-- Make inlay hints visible (only if neovim is new enough)
if vim.fn.has('nvim-0.10.0') == 1 then
    vim.lsp.inlay_hint.enable(true)
end

return M

--[[
------------------------------------------------------------
Footnotes -----------------------------------------------
------------------------------------------------------------

[^1] https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
[^1] https://teddit.net/r/neovim/comments/r5kwg7/rounded_corners_for_popup_menus/
[^1] https://github.com/akinsho/dotfiles/blob/41f327dd47d91af42d1ed050745b85f422b87365/.config/nvim/plugin/lsp.lua#L184-L194
[^fn_tx40m2]: https://www.reddit.com/r/neovim/comments/tx40m2/is_it_possible_to_improve_lsp_hover_look/

--]]
