-- Define the state of the snippy environment
-- so that we can modify snippy dynamically
-- in the expand_options
My_snippy_state = {
	---@type boolean
	contextual = true,
	auto = true,
	---@enum mode
	Mode = {
		latex = false,
		markdown = false,
		python = false,
		r = false,
	},
	toggles = {
		latex = function()
			My_snippy_state.Mode.latex = not My_snippy_state.Mode.latex
		end,
		contextual = function()
			My_snippy_state.contextual = not My_snippy_state.contextual
		end,
	},
}

require("snippy").setup({
	enable_auto = true,
	virtual_markers = {
		enabled = true,
		-- Marker for all placeholders (non-empty)
		default = "◁",
		-- Marker for all empty tabstops
		empty = "▷",
		-- Marker highlighing
		hl_group = "SnippyMarker",
	},
	expand_options = {
		-- Here we can create optional environments for things
		-- e.g. modal snippets based on an env var:
		l = function()
			return My_snippy_state.Mode.latex
		end,
		-- Snippets dependent on a treesitter environment etc.
		m = function()
			return require("utils/tsutils_math").in_mathzone() and My_snippy_state.contextual
		end,
		c = function()
			return require("utils/tsutils_math").in_comment() and My_snippy_state.contextual
		end,
	},
})

-- The Tab Mapping bound in
-- ~/.config/nvim/lua/keymaps.lua | 222
