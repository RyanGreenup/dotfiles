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

local providers = {
  cerebras = {
    api_key = "CEREBRAS_API_KEY",
    end_point = "https://api.cerebras.ai/v1/chat/completions",
    model = "qwen-3-235b-a22b-instruct-2507",
    name = "cerebras",
    stream = true,
    optional = {
      max_tokens = 256,
      stream_options = { include_usage = true },
    },
  },
  cerebras_llama = {
    api_key = "CEREBRAS_API_KEY",
    end_point = "https://api.cerebras.ai/v1/chat/completions",
    model = "llama3.1-8b",
    name = "cerebras",
    stream = true,
    optional = {
      max_tokens = 256,
      stream_options = { include_usage = true },
    },
  },
  -- gpt-oss-120b is a reasoning model: streaming sends delta.reasoning chunks
  -- that minuet can't parse. Use stream=false so the full content field is returned.
  cerebras_reasoning = {
    api_key = "CEREBRAS_API_KEY",
    end_point = "https://api.cerebras.ai/v1/chat/completions",
    model = "gpt-oss-120b",
    name = "cerebras",
    stream = false,
    optional = {
      max_tokens = 512,
      reasoning_effort = "low",
    },
  },
  openai = {
    api_key = function()
      local f = io.open(vim.fn.expand("~/.local/keys/openai.key"), "r")
      if not f then return "" end
      local key = f:read("*l")
      f:close()
      return key
    end,
    end_point = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4.1-mini",
    name = "openai",
    stream = true,
    optional = {
      max_tokens = 256,
    },
  },
}

-- Usage tracker: calls bun-minuet-tracker for session cost summaries
local session_start = tostring(os.time())
local tracker_dir = vim.fn.stdpath("config") .. "/scripts/bun-minuet-tracker"

local M = {}

function M.run_setup()
  local provider = providers[cfg.provider] or providers.cerebras

  -- Use the curl wrapper that logs token usage
  local curl_wrapper = vim.fn.stdpath("config") .. "/scripts/minuet-curl"

  require("minuet").setup({
    provider = "openai_compatible",
    curl_cmd = curl_wrapper,
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
      openai_compatible = provider,
    },
  })

  local function log(msg)
    if cfg.debug then
      vim.notify("[minuet] " .. msg, vim.log.levels.INFO)
    end
  end

  log("provider=" .. cfg.provider
    .. " model=" .. provider.model
    .. " endpoint=" .. provider.end_point
    .. " api_key_type=" .. type(provider.api_key))

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

  -- Debug: log request lifecycle (gated by config.minuet.debug)
  vim.api.nvim_create_autocmd("User", {
    pattern = "MinuetRequestStartedPre",
    group = group,
    callback = function(ev)
      local d = ev.data or {}
      log("request PRE: provider=" .. tostring(d.name)
        .. " model=" .. tostring(d.model)
        .. " n_requests=" .. tostring(d.n_requests))
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MinuetRequestStarted",
    group = group,
    callback = function(ev)
      local d = ev.data or {}
      log("request STARTED: idx=" .. tostring(d.request_idx))
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MinuetRequestFinished",
    group = group,
    callback = function(ev)
      local d = ev.data or {}
      log("request FINISHED: idx=" .. tostring(d.request_idx))
    end,
  })

  -- :MinuetTestCurl -- always available, sends a simple request to verify the endpoint
  vim.api.nvim_create_user_command("MinuetTestCurl", function()
    local key
    if type(provider.api_key) == "function" then
      key = provider.api_key()
    else
      key = vim.env[provider.api_key] or ""
    end
    vim.notify("[minuet-test] key length=" .. #key .. " first4=" .. key:sub(1, 4), vim.log.levels.INFO)

    local body = vim.json.encode({
      model = provider.model,
      messages = { { role = "user", content = "Say hello in 5 words." } },
      max_tokens = 32,
      stream = false,
    })
    local tmp = vim.fn.tempname()
    local f = io.open(tmp, "w")
    if not f then
      vim.notify("[minuet-test] failed to create temp file", vim.log.levels.ERROR)
      return
    end
    f:write(body)
    f:close()

    vim.fn.jobstart({
      "curl", "-s", "-w", "\n%{http_code}",
      "-H", "Content-Type: application/json",
      "-H", "Authorization: Bearer " .. key,
      "-d", "@" .. tmp,
      provider.end_point,
    }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        local output = table.concat(data, "\n")
        vim.schedule(function()
          vim.notify("[minuet-test] response:\n" .. output:sub(1, 500), vim.log.levels.INFO)
        end)
      end,
      on_stderr = function(_, data)
        local err = table.concat(data, "\n")
        if #err > 0 then
          vim.schedule(function()
            vim.notify("[minuet-test] stderr: " .. err:sub(1, 300), vim.log.levels.WARN)
          end)
        end
      end,
    })
  end, { desc = "Test minuet provider with a simple curl request" })

  -- Toggle auto-suggest on/off
  vim.keymap.set("n", cfg.toggle, function()
    require("minuet.virtualtext").action.toggle_auto_trigger()
  end, { desc = "Minuet: toggle auto-suggest" })

  -- Cost display: runs bun-minuet-tracker and shows the result
  local function show_usage()
    vim.fn.jobstart({
      "bun", "run", tracker_dir .. "/index.ts",
      "--since", session_start,
      "--input-rate", tostring(cfg.cost_per_million_input),
      "--output-rate", tostring(cfg.cost_per_million_output),
    }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        local output = vim.trim(table.concat(data, "\n"))
        if #output > 0 then
          vim.schedule(function()
            vim.notify("[minuet] " .. output, vim.log.levels.INFO)
          end)
        end
      end,
    })
  end

  vim.keymap.set("n", cfg.cost_display, show_usage, { desc = "Minuet: show session cost" })
  vim.api.nvim_create_user_command("MinuetUsage", show_usage, { desc = "Show minuet session token usage and cost" })
end

return M
