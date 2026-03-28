local M = {}

local timer = nil
local stopped = false
local enabled = true

--- Stop all running LSP clients.
local function stop_all_clients()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    return
  end
  for _, client in ipairs(clients) do
    client:stop()
  end
  stopped = true
end

--- Restart LSP by re-triggering FileType autocmds on loaded buffers.
local function restart_clients()
  if not stopped then
    return
  end
  stopped = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
      vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
    end
  end
end

--- Cancel the pending stop timer if one exists.
local function cancel_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

function M.setup(opts)
  opts = opts or {}
  local timeout_ms = (opts.timeout_minutes or 5) * 60 * 1000

  local group = vim.api.nvim_create_augroup('LspLifecycle', { clear = true })

  vim.api.nvim_create_autocmd('FocusLost', {
    group = group,
    callback = function()
      if not enabled then
        return
      end
      cancel_timer()
      timer = vim.uv.new_timer()
      timer:start(timeout_ms, 0, vim.schedule_wrap(function()
        cancel_timer()
        stop_all_clients()
      end))
    end,
  })

  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = function()
      cancel_timer()
      if stopped then
        restart_clients()
      end
    end,
  })

  vim.api.nvim_create_user_command('LspLifecycleToggle', function()
    enabled = not enabled
    if not enabled then
      cancel_timer()
    end
    vim.notify('LSP lifecycle: ' .. (enabled and 'enabled' or 'disabled'))
  end, {})
end

return M
