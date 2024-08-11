--- This toggles an autocommand to open evey markdown file in vscode
--- Convenient for previewing markdown files
local M = {} -- define a table to hold our module

local markdown_preview_enabled = false
-- Store the autogroup ID in this variable
local autopreview_group

function Jobstart(command)
  if type(command) == "string" then
    print(command)
  elseif type(command) == "table" then
    print(table.concat(command, " "))
  end
  vim.fn.jobstart(command)
end

local function Enable_markdown_auto_preview()
  -- FileType autocommand in Vim
  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
    pattern = "markdown",
    group = autopreview_group,
    callback = function()
      Jobstart(string.format("codium --disable-gpu %s", vim.fn.expand("%")))
      vim.cmd([[  autocmd BufEnter *.md :setlocal filetype=markdown ]])
    end,
    desc = "Open in VSCode for Preview"
  })
end

local function disable_markdown()
  if autopreview_group then
    vim.api.nvim_del_augroup_by_id(autopreview_group)
    -- Reset the variable to avoid trying to delete a non-existent group
    autopreview_group = nil
  end
end

function Toggle_auto_preview()
  if markdown_preview_enabled then
    disable_markdown()
    markdown_preview_enabled = false
  else
    -- Create the autogroup when enabling, not when disabling
    autopreview_group = vim.api.nvim_create_augroup("MarkdownAutoPreview", { clear = true })
    Enable_markdown_auto_preview()
    markdown_preview_enabled = true
  end
end

--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Define the function we want to export
function M.toggle()
  Toggle_auto_preview()
end

return M
