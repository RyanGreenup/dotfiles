--- Minuet: LLM-powered inline code completions.
---
--- Files:
---   settings.lua - provider config, spinner, keybindings
---   config.lua   - keybinding overrides (in lua/config.lua under `minuet`)

return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.minuet.settings").run_setup()
    end,
  },
}
