local M = {}

function M.run_setup()
  local ls = require("luasnip")

  ls.config.setup({
    enable_autosnippets = true,
    region_check_events = "InsertEnter",
    delete_check_events = "TextChanged",
    store_selection_keys = "<Tab>",
  })

  -- Load snipmate-format snippets from snippets/ dir
  require("luasnip.loaders.from_snipmate").lazy_load({
    paths = { vim.fn.stdpath("config") .. "/snippets" },
  })

  -- Load native Lua snippets from LuaSnip/ dir
  require("luasnip.loaders.from_lua").lazy_load({
    paths = { vim.fn.stdpath("config") .. "/LuaSnip" },
  })
end

return M
