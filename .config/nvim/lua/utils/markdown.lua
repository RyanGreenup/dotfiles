--------------------------------------------------------------------------------
-- Markdown Stuff --------------------------------------------------------------
--------------------------------------------------------------------------------

-- Organisation Stuff ----------------------------------------------------------
require("utils/increment_time_stamps")
require("utils/open_journal_files")
require("utils/paths")


function File_exists(path)
  return vim.fn.filereadable(path) == 1
end

--[[
Convert a string to kebab case
Dendron recommends lower case kebab case with dots to separate
Upon reflection, I agree, it makes things simpler

Example:
  "My Title" -> "my-title"
--]]
function Kebab_case(user_string)
  out = user_string
  -- Replace Slashes with Dots
  out = string.gsub(out, " / ", ".")
  out = string.gsub(out, "/", ".")
  -- Replace spaces with dashes
  out = string.gsub(out, " ", "-")
  -- Lower case
  out = string.lower(out)
  return out
end

function Build_markdown_link(title, path)
  return "[".. title.. "](".. path.. ")"
end

function Open_file_in_split(path, insert)
  -- split
  vim.api.nvim_command('split')
  vim.api.nvim_command('wincmd j')
  -- Create the file
  vim.api.nvim_command('e ' .. path)
  -- vim.api.nvim_command('wincmd k')

  -- Check that insert isn't empty
  if insert ~= "" then
    -- Insert the text
    vim.api.nvim_set_current_line(insert)
    -- Open a new line
    vim.cmd("normal! o")
    vim.cmd("normal! o")
  end
end


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
  local dir_path = Dirname(path)
  local filename = Strip_extension(Basename(path))

  -- Take the current line as the name of the sub page
  local title = vim.api.nvim_get_current_line()

  -- Adjust the title a little bit
  sub_page = Kebab_case(title)

  -- Insert the sub_page before the extension
  local new_path = filename .. '.' .. Kebab_case(sub_page) .. '.md'
  local link = Build_markdown_link('➡️ /' .. title, new_path)

  -- Set the new line as the link
  vim.api.nvim_set_current_line(link)


  if File_exists(new_path) then
    Open_file_in_split(new_path, "")
  else
    Open_file_in_split(new_path, "# " .. title)
  end

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
