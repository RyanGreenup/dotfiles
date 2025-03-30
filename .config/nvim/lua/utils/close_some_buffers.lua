local M = {} -- define a table to hold our module

-- Close all buffers except the current one
function M.close_all_except_current()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) and buf ~= current_buf then
      local is_listed = vim.bo[buf].buflisted
      -- local is_listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
      if is_listed and vim.api.nvim_buf_is_loaded(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end
end

-- Create vim command
function M.setup()
  vim.api.nvim_create_user_command('KillOtherBuffers', function()
    M.close_all_except_current()
  end, {})
end

-- Return the module table so that it can be required by other scripts
return M
