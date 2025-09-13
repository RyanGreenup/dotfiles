--- Module for changing the current working directory in Neovim
--- Provides utilities for navigating to file directories
---
--- Usage:
---   require('utils.change_directory').change_to_file_dir()
---
---@module 'utils.change_directory'
local M = {}

--- Gets a valid file path from the clipboard
--- Returns the expanded file path or nil if invalid
---@return string|nil
local function get_clipboard_filepath()
  local clipboard_content = vim.fn.getreg('+')
  if clipboard_content == '' then
    vim.notify('Clipboard is empty', vim.log.levels.WARN)
    return nil
  end

  -- Trim whitespace and expand the path
  local filepath = vim.fn.trim(clipboard_content)
  filepath = vim.fn.expand(filepath)

  if vim.fn.filereadable(filepath) == 1 then
    return filepath
  else
    vim.notify('Clipboard does not contain a valid file path: ' .. filepath, vim.log.levels.WARN)
    return nil
  end
end

--- Finds the git root directory for a given path
--- Returns the git root path or nil if not found
---@param start_path string The starting directory to search from
---@return string|nil
local function find_git_root(start_path)
  local git_dir = vim.fn.finddir('.git', start_path .. ';')
  if git_dir ~= '' then
    return vim.fn.fnamemodify(git_dir, ':h')
  end
  return nil
end

--- Changes the current working directory to the directory of the current file
--- Shows a notification with the new directory path
--- If no file is open, shows a warning notification
--- Essentially function() vim.cmd [[:cd %:p:h]] end
function M.change_to_file_dir()
  local file_dir = vim.fn.expand('%:p:h')
  if file_dir ~= '' then
    vim.cmd('cd ' .. vim.fn.fnameescape(file_dir))
    vim.notify('Changed directory to: ' .. file_dir)
  else
    vim.notify('No file open', vim.log.levels.WARN)
  end
end

--- Changes to the nearest parent directory containing a .git folder
--- Searches upward from the current file's directory
--- If no git repository is found, shows a warning notification
function M.change_to_git_root()
  local current_file = vim.fn.expand('%:p')
  local start_dir = current_file ~= '' and vim.fn.fnamemodify(current_file, ':h') or vim.fn.getcwd()

  local git_root = find_git_root(start_dir)
  if git_root then
    vim.cmd('cd ' .. vim.fn.fnameescape(git_root))
    vim.notify('Changed directory to git root: ' .. git_root)
  else
    vim.notify('No git repository found', vim.log.levels.WARN)
  end
end

--- Changes to the directory of the filepath in the system clipboard and opens that file
--- Uses the system clipboard (+ register) to get the filepath
--- If the clipboard doesn't contain a valid file path, shows a warning
function M.change_to_clipboard_file()
  local filepath = get_clipboard_filepath()
  if not filepath then return end

  local file_dir = vim.fn.fnamemodify(filepath, ':h')
  vim.cmd('cd ' .. vim.fn.fnameescape(file_dir))
  vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
  vim.notify('Opened file and changed to: ' .. file_dir)
end

--- Changes to the git root of the file path in the clipboard and opens that file
--- Uses the system clipboard (+ register) to get the filepath
--- If no git repository is found, changes to the file's directory instead
function M.change_to_clipboard_file_git_root()
  local filepath = get_clipboard_filepath()
  if not filepath then return end

  local file_dir = vim.fn.fnamemodify(filepath, ':h')
  local git_root = find_git_root(file_dir)

  if git_root then
    vim.cmd('cd ' .. vim.fn.fnameescape(git_root))
    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
    vim.notify('Opened file and changed to git root: ' .. git_root)
  else
    -- Fallback to file directory if no git root found
    vim.cmd('cd ' .. vim.fn.fnameescape(file_dir))
    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
    vim.notify('No git root found. Opened file and changed to: ' .. file_dir)
  end
end

return M
