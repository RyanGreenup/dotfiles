--- Minuet setup: provider config, spinner, and keybindings.
--- Keybindings are read from lua/config.lua so colleagues can override them.

local cfg = require("config").minuet

-- Loading spinner: animates at end of cursor line during API requests
local spinner = {
  frames = { ".", "..", "..." },
  ns = vim.api.nvim_create_namespace("minuet_spinner"),
  idx = 0,
  timer = nil,
  active = false,
}

local function spinner_start()
  if spinner.active then return end
  spinner.active = true
  spinner.idx = 0
  spinner.timer = vim.uv.new_timer()
  spinner.timer:start(0, 200, vim.schedule_wrap(function()
    if not spinner.active then return end
    spinner.idx = (spinner.idx % #spinner.frames) + 1
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(buf, spinner.ns, 0, -1)
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    pcall(vim.api.nvim_buf_set_extmark, buf, spinner.ns, row, 0, {
      virt_text = { { spinner.frames[spinner.idx], "NonText" } },
      virt_text_pos = "eol",
    })
  end))
end

local function spinner_stop()
  spinner.active = false
  if spinner.timer then
    spinner.timer:stop()
    spinner.timer:close()
    spinner.timer = nil
  end
  pcall(function()
    vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), spinner.ns, 0, -1)
  end)
end

local M = {}

function M.run_setup()
  require("minuet").setup({
    provider = "openai_compatible",
    n_completions = 3,
    context_window = 512,
    request_timeout = 15,
    throttle = 1500,
    debounce = cfg.debounce,
    virtualtext = {
      -- Starts disabled. Toggle with the keybinding in config.lua.
      auto_trigger_ft = {},
      keymap = {
        accept = cfg.accept,
        dismiss = cfg.dismiss,
        next = cfg.next,
        prev = cfg.prev,
      },
    },
    provider_options = {
      openai_compatible = {
        api_key = function()
          local f = io.open(vim.fn.expand("~/.local/keys/openai.key"), "r")
          if not f then return "" end
          local key = f:read("*l")
          f:close()
          return key
        end,
        end_point = "https://api.openai.com/v1/chat/completions",
        model = "gpt-4.1-mini",
        name = "gpt-4.1-mini",
        stream = true,
        optional = {
          max_tokens = 256,
        },
      },
    },
  })

  -- Spinner autocmds
  local group = vim.api.nvim_create_augroup("MinuetSpinner", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MinuetRequestStarted",
    group = group,
    callback = spinner_start,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MinuetRequestFinished",
    group = group,
    callback = spinner_stop,
  })

  -- Toggle auto-suggest on/off
  vim.keymap.set("n", cfg.toggle, function()
    require("minuet.virtualtext").action.toggle_auto_trigger()
  end, { desc = "Minuet: toggle auto-suggest" })
end

return M
