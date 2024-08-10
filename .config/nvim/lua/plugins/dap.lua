return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
		{ "theHamsta/nvim-dap-virtual-text", opts = { enabled = true } },
		"nvim-telescope/telescope-dap.nvim",
	},
	config = function()
		require("dapui").setup()
		require("dap-python").setup("~/.local/share/virtualenvs/debugpy/bin/python")
		require("keymaps").dap_keymaps()
	end,
}
