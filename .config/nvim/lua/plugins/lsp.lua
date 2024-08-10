local M = {} -- define a table to hold our module
local lsp = vim.lsp

-- Imports
local lspconfig = require('lspconfig')
local servers = require('plugins/lsp_server_list').servers

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_available = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_available then
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
else
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end

--------------------------------------------------------------------------------
-- Tables ----------------------------------------------------------------------
--------------------------------------------------------------------------------
local outside_normal_maps = {
  { "<space>e", vim.diagnostic.open_float },
  { "[d",       vim.diagnostic.goto_prev },
  { "<F8>",     vim.diagnostic.goto_prev },
  { "]d",       vim.diagnostic.goto_next },
  { "<space>q", vim.diagnostic.setloclist } }

-- Ommitted because it's auto
--	vim.api.nvim_buf_set_keymap(bufnr, "i", "<A-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
local on_attach_normal_maps = {
  { "gD",        vim.lsp.buf.declaration },
  { "gd",        vim.lsp.buf.definition },
  { "K",         vim.lsp.buf.hover },
  { "gi",        vim.lsp.buf.implementation },
  { "<A-k>",     vim.lsp.buf.signature_help },
  { "<space>wa", vim.lsp.buf.add_workspace_folder },
  { "<space>wr", vim.lsp.buf.remove_workspace_folder },
  { "<space>wd", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
  { "<space>D",  vim.lsp.buf.type_definition },
  { "<space>rn", vim.lsp.buf.rename },
  { "<space>ca", vim.lsp.buf.code_action },
  { "gr",        vim.lsp.buf.references },
}


--------------------------------------------------------------------------------
-- Helper Functions ------------------------------------------------------------
--------------------------------------------------------------------------------

-- .............................................................................
-- Configure LSP ...............................................................
-- .............................................................................

--- Set keymaps for LSP
---@param key string
---@param callback function
local function nmap(key, callback, mode, bufnr)
  mode = mode or "n"
  if bufnr == nil then
    vim.api.nvim_set_keymap(mode, key, '', { noremap = true, silent = true, callback = callback })
  else
    vim.api.nvim_buf_set_keymap(bufnr, mode, key, '', { noremap = true, silent = true, callback = callback })
  end
end

local function set_lsp_keymaps(bufnr)
  for _, keybinding in ipairs(outside_normal_maps) do
    nmap(keybinding[1], keybinding[2])
  end

  for _, keybinding in ipairs(on_attach_normal_maps) do
    nmap(keybinding[1], keybinding[2], "n", bufnr)
  end
end

local enable_inlay_hints_if_provided = function(client)
  if client.server_capabilities.inlayHintProvider then
    -- Enable Hints
    vim.g.inlay_hints_visible = true
  end
end

local on_attach = function(client, bufnr)
  enable_inlay_hints_if_provided(client)
  set_lsp_keymaps(bufnr)
  if not cmp_nvim_lsp_available then
    vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
  end
end

local function configure_lua_ls()
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
  })
end


--- Configure the Julia LSP the JIT makes this a pain
local function configure_julia_lsp_server()
  lspconfig.julials.setup({
    on_new_config = function(new_config, _)
      local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
      new_config.cmd[1] = julia
    end,
    -- This just adds dirname(fname) as a fallback (see nvim-lspconfig#1768).
    root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern("Project.toml")(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
    end,
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

--- Configure the LSP Servers, this is the important function
local function configure_lsp_servers()
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      basedpyright = {
        typeCheckingMode = "standard",
      },
      pyright = {
        typeCheckingMode = "standard",
      }
    }
  }

  local sqlls_opts = {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "sql", "mysql", ".pgsql" },
    root_dir = function()
      return vim.loop.cwd()
    end,
    -- cmd = {"sql-language-server", "up", "--method", "stdio"};
  }

  for _, s in pairs(servers) do
    if lsp == "sqlls" then
      require("lspconfig")[s].setup(sqlls_opts)
    else
      require("lspconfig")[s].setup(opts)
    end
  end
end

-- .............................................................................
-- Formatting the Displays .....................................................
-- .............................................................................

--- Fix the hover in Pyright to remove HTML [^fn_tx40m2]
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

local my_border = {
  { "┌", "FloatBorder" },
  { "─", "FloatBorder" },
  { "┐", "FloatBorder" },
  { "│", "FloatBorder" },
  { "┘", "FloatBorder" },
  { "─", "FloatBorder" },
  { "└", "FloatBorder" },
  { "│", "FloatBorder" },
}


local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)

-- TODO do max_width and max_height need to be be lambdas ?
local document_hover_opts = {
  border = my_border, -- could be 'single', 'double',
  -- 'shadow', 'rounded', 'solid'
  -- or `my_border` from above
  max_width = max_width,
  max_height = max_height,
}

local signature_hover_opts = {
  border = "shadow", -- could be 'single', 'double', 'shadow', 'rounded', 'solid'
  max_width = max_width,
  max_height = max_height,
}

local diagnostic_opts = {
  virtual_text = {
    prefix = "●", -- Could be '●', '▎', 'x'
    source = "always", -- Or "if_many"
  },
  float = {
    source = "always", -- Or "if_many"
  },
}

local function set_lsp_highlights()
  vim.cmd([[
  highlight! DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
  highlight! DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
  highlight! DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
  highlight! DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]])
end

--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Define the function we want to export
function M.run_setup()
  -- Configgure the servers
  configure_lua_ls()
  configure_julia_lsp_server()
  configure_lsp_servers()
  -- Configure the Hover, signature and diagnostic display
  lsp.handlers["textDocument/hover"] = lsp.with(clean_hover, document_hover_opts)
  lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, signature_hover_opts)
  vim.diagnostic.config(diagnostic_opts)
  set_lsp_highlights()
end

-- Return the module table so that it can be required by other scripts
return M
