--------------------------------------------------------------------------------
-- Markdown Stuff --------------------------------------------------------------
--------------------------------------------------------------------------------

-- Organisation Stuff ----------------------------------------------------------
require("utils/increment_time_stamps")
require("utils/open_journal_files")



--[[
Create a markdown link to a sub page

Example:

# Type this line
sub-page

# Have it replaced with this link to sub-page
[➡️ /sub-page](filename.sub-page.md)

--]]
function Create_markdown_link()
  -- Get the current buffer name
  local path = vim.api.nvim_buf_get_name(0)

  -- Get the base dir and filename
  local base_path = string.gmatch(path, "[^/]*$")()
  local dir_path = string.gsub(path, base_path, "")
  local filename = string.gmatch(base_path, "%w+")()

  -- Take the current line as the name of the sub page
  local line = vim.api.nvim_get_current_line()
  local sub_page = line

  -- Replace spaces with dashes
  sub_page = string.gsub(sub_page, " ", "-")

  -- Create the new path and link
  local new_path = filename .. '.' .. sub_page .. '.md'
  local link = '[➡️ /' .. sub_page .. '](' .. new_path .. ')'

  -- Check if that file exists
  local exists = false
  if vim.fn.filereadable(dir_path .. new_path .. '.md') == 0 then
    print("here")
    -- split
    vim.api.nvim_command('split')
    vim.api.nvim_command('wincmd j')
    -- Create the file
    vim.api.nvim_command('e ' .. new_path)
    vim.api.nvim_command('wincmd k')
  end


  -- Set the new line as the link
  local new_line = link
  vim.api.nvim_set_current_line(new_line)
end

-- Create a comamand
vim.cmd("command! CreateMarkdownLink lua Create_markdown_link()")

--[[
Creates a mermaid diagram using a python script from the system
--]]
function Create_mermaid()
  -- Cut the current paragraph to the clipboard
  vim.cmd("normal! vip")
  vim.cmd("normal! \"*y")

  -- Run the shell command and capture the output
  HOME = os.getenv("HOME")
  local cmd = HOME .. "/.local/bin/journal.schedule.vis.mermaid.py"
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  -- paste the output of that command
  vim.cmd([[normal! G]])
  vim.cmd([[normal! "*p]])
end
vim.cmd("command! CreateMermaid lua Create_mermaid()")
