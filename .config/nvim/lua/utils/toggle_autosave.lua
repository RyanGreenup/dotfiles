--- This toggles an autocommand to save and revert on TextChanged
--- i.e. Autosave
local M = {} -- define a table to hold our module

-- TODO this logic is repeated in markdown_toggle_autocmd_vscode.lua
-- This should be refactored into a shared module that takes:
--     1. A callback
--     2. A table of Events
--     3. A pattern that defaults to '*'

local autosave_enabled = false
-- Store the autogroup ID in this variable
local autosave_group
local autoread_orig = vim.opt.autoread
vim.opt.autoread = true

local function enable_autosave()
  -- FileType autocommand in Vim
  -- consider CursorChanged and InsertLeave
  vim.opt.autoread = true
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = "*",
    group = autosave_group,
    callback = function()
      vim.cmd("silent! update")

      -- Run feedkeys('lh') command to refresh the screen
      vim.cmd("redraw!")
      -- vim.cmd("edit!")
    end,
    desc = "Write on any change to file"
  })
end

local function disable_autosave()
  vim.opt.autoread = autoread_orig
  if autosave_group then
    vim.api.nvim_del_augroup_by_id(autosave_group)
    -- Reset the variable to avoid trying to delete a non-existent group
    autosave_group = nil
  end
end

function Toggle_auto_save()
  if autosave_enabled then
    disable_autosave()
    autosave_enabled = false
  else
    -- Create the autogroup when enabling, not when disabling
    autosave_group = vim.api.nvim_create_augroup("Autosave", { clear = true })
    enable_autosave()
    autosave_enabled = true
  end
end

--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------

--- Toggle autosave (disabled by default)
function M.toggle()
  Toggle_auto_save()
end

return M
