local M = {} -- define a table to hold our module

local cmp = require("cmp")
local map = cmp.mapping

--------------------------------------------------------------------------------
-- Helper Functions ------------------------------------------------------------
--------------------------------------------------------------------------------

local lspkind = require("lspkind")

lspkind.init({
	mode = "symbol",
	preset = "codicons",
})

--- @param entry any
--- @param vim_item any
--- Formats the given entry and vim_item based on the provided mode and maxwidth.
--- This function uses lspkind to format the item, then extracts and reformats the kind property of the result.
local function format_function(entry, vim_item)
	local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
	local strings = vim.split(kind.kind, "%s", { trimempty = true })
	kind.kind = " " .. (strings[1] or "") .. " "
	kind.menu = "    (" .. (strings[2] or "") .. ")"

	return kind
end

local lspkind_formatting = require("lspkind").cmp_format({
	mode = "symbol",
	maxwidth = function()
		return math.floor(0.45 * vim.o.columns)
	end,
	ellipsis_char = "...",
	show_labelDetails = true,
})

--- Expands the given snippet body using the specified snippet library.
-- This function is intended to be used as a callback for a completion source in Neovim.
-- @param args table A table containing the arguments passed by Neovim's completion API. The 'body' field of this table contains the text that needs to be expanded into a snippet.
local function snippet_expand(args)
	-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
	-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
	-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
	require("snippy").expand_snippet(args.body) -- For `snippy` users.
end

--- Table of completions for the cmp menu
local cmp_completions = {
	-- https://teddit.net/r/neovim/comments/u7nsje/nvimcmp_completion_issue_cn_gives_basic_completion/
	["<C-k>"] = map(map.scroll_docs(-4), { "i", "c" }),
	["<C-n>"] = map(map.select_next_item(), { "i", "c" }),
	["<C-p>"] = map(map.select_prev_item(), { "i", "c" }),
	["<C-j>"] = map(map.scroll_docs(4), { "i", "c" }),
	["<C-Space>"] = map(map.complete(), { "i", "c" }),
	["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
	["<C-e>"] = map({
		i = map.abort(),
		c = map.close(),
	}),
	["<CR>"] = map.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
}

local markdown_oxide_opts = {
	nvim_lsp_opt = { keyword_pattern = [[\(\k\| \|\/\|#\)\+]] },
}

local nvim_lsp_opts = {
	markdown_oxide = {
		markdown_oxide_opts.nvim_lsp_opt,
	},
}

local cmp_sources = {
	{ name = "nvim_lsp", option = { nvim_lsp_opts } },
	{ name = "nvim_lsp_signature_help" },
	{ name = "nvim_lsp" },
	{ name = "otter" },
	{ name = "conjure" },
	{ name = "snippy" },
	{ name = "buffer" },
	{ name = "path" },
}

--------------------------------------------------------------------------------
-- Options Table ---------------------------------------------------------------
--------------------------------------------------------------------------------

--- Default options to give to cmp
local opts = {
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = lspkind_formatting,
	},
	snippet = { expand = snippet_expand },
	mapping = cmp_completions,
	sources = cmp.config.sources(cmp_sources),
}

--- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
local cmdline_slash_opts = {
	sources = {
		{ name = "buffer" },
	},
}

--- Use path and cmdline source for `:`
local cmdline_colon_opts = {
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
}

--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Define the function we want to export
function M.run_setup()
	cmp.setup(opts)
	cmp.setup.cmdline("/", cmdline_slash_opts)
	cmp.setup.cmdline(":", cmdline_colon_opts)
end

-- Return the module table so that it can be required by other scripts
return M
