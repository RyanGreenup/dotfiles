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
  local out
  out = user_string
  -- Replace Slashes with Underscore
  out = string.gsub(out, " / ", "_")
  out = string.gsub(out, "/", "_")
  -- Replace spaces with dashes
  out = string.gsub(out, " ", "-")
  -- Lower case
  out = string.lower(out)
  return out
end

function Build_markdown_link(title, path)
  return "[" .. title .. "](" .. path .. ")"
end


--[[
Create a markdown link to a sub page

Example:

# Type this line
sub-page

# Have it replaced with this link to sub-page
[➡️ /sub-page](filename_sub-page.md)

- `_` represents heirarchy (not dot because wikijs doesn't support that)
    - otherwise consistent with dendron.

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
  local new_path = filename .. '_' .. Kebab_case(sub_page) .. '.md'
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


--------------------------------------------------------------------------------
-- Notetaking Stuff ------------------------------------------------------------
--------------------------------------------------------------------------------

require('utils/directories')
function Insert_notes_link()
  -- Use the current buffer as the notes directory in case of other wiki
  local notes_dir = "--notes_dir "
  notes_dir = notes_dir .. Get_dirname_buffer() .. " "
  local current_buffer = "-c " .. vim.api.nvim_get_current_buf() .. " "

  local cmd = "~/.local/scripts/python/notes/make_link.py -g "
  cmd = cmd .. notes_dir .. current_buffer

  -- current_link=Shell("cd ~/Notes/slipbox/ && fd -t f . | rofi -dmenu")
  local current_link = Shell(cmd)
  -- Assert the link is not empty
  if current_link == nil then
    print("No link selected")
    return
  end
  -- Strip the trailing new line (TODO: Should this be done in the function?)
  current_link = string.gsub(current_link, "\n$", "")
  -- insert the link into the current buffer
  vim.api.nvim_put({ current_link }, "l", true, true)
end

--------------------------------------------------------------------------------
-- Generate a Navigation Tree --------------------------------------------------
--------------------------------------------------------------------------------
function Generate_navigation_tree()
  -- Build the command
  local HOME = Get_HOME()
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local notes_dir = Get_dirname_buffer()

  local cmd = HOME .. "/.local/scripts/python/notes/generate-navigation.py "
  cmd = cmd .. current_file_path .. " "
  cmd = cmd .. notes_dir


  -- Run the command and get the output
  local navigation_tree_string = Shell(cmd)
  if navigation_tree_string == nil then
    print("No navigation tree generated")
    return
  end


  -- Split the output into a list of lines
  local lines = {}
  for line in navigation_tree_string:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end


  -- Insert the output
  vim.api.nvim_put(lines, "l", true, true)
end