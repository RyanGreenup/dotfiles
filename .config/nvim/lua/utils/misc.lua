local M = {} -- define a table to hold our module



local function conceal_toggle()
  local conceal_level = vim.api.nvim_get_option_value('conceallevel', {})
  conceal_level = tonumber(conceal_level)
  local new_level = (conceal_level + 1) % 3
  vim.api.nvim_set_option_value('conceallevel', new_level, {})
  local message = "Conceal level: " .. conceal_level .. " --> " .. new_level
  print(message)
end

--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------

function M.conceal_toggle()
  conceal_toggle()
end

function M.open_file(path, change_dir)
  if change_dir == nil then
    change_dir = false
  end
  local path_dir = vim.fn.fnamemodify(path, ':h')
  vim.cmd('edit ' .. path)
  vim.cmd('cd' .. path_dir)
end

function M.open_config()
  M.open_file('~/.config/nvim/init.lua')
end

-- TODO use env var for notes path
function M.open_clipboard()
  M.open_file(vim.fn.getreg('+'))
end

function M.open_notes()
  M.open_file('~/Notes/slipbox/home.md')
end

function M.copy_path(no_tilde, drop_cwd)
  if drop_cwd == nil then
    drop_cwd = false
  end
  if no_tilde == nil then
    no_tilde = false
  end
  local path = vim.api.nvim_buf_get_name(0)
  if no_tilde then
    vim.fn.setreg('+', path)
  else
    local home = os.getenv("HOME")
    if home ~= nil then
      path = path:gsub(home, "~")
    end

    if drop_cwd then
      local cwd = vim.fn.getcwd()
      if cwd ~= nil then
        path = path:gsub(vim.fn.getcwd() .. "/", "")
      end
    end
    vim.fn.setreg('+', path)
  end
end

function M.copy_base_path()
  M.copy_path(true, true)
end

-- Return the module table so that it can be required by other scripts
return M
