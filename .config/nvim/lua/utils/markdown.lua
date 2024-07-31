--------------------------------------------------------------------------------
-- Markdown Stuff --------------------------------------------------------------
--------------------------------------------------------------------------------

-- Organisation Stuff ----------------------------------------------------------
require("utils/increment_time_stamps")
require("utils/open_journal_files")
require("utils/paths")
require("utils/lists")


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

@param subpage bool (optional) whether the new page should be a subpage
--]]
function Create_markdown_link(subpage)
  if subpage == nil then
    subpage = false
  end
  -- Get the current buffer name
  local path = vim.api.nvim_buf_get_name(0)

  -- Get the base dir and filename
  local dir_path = Dirname(path)
  local filename = Strip_extension(Basename(path))

  -- Take the current line as the name of the sub page
  local title = vim.api.nvim_get_current_line()

  -- Adjust the title a little bit
  local sub_page = Kebab_case(title)

  local link
  local new_path
  -- Insert the sub_page before the extension
  if subpage then
    new_path = filename .. '_' .. Kebab_case(sub_page) .. '.md'
    link = Build_markdown_link('/' .. title, new_path)
  else
    new_path = sub_page .. ".md"
    link = Build_markdown_link(title, new_path)
  end

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
Format a url in the clipboard as a markdown link
--]]

function Format_url_markdown()
  -- Get the current buffer name
  local path = vim.api.nvim_buf_get_name(0)

  local url = Shell("wl-paste | tr -d '\n'")
  print(url)
  local link = Shell("note_taking url md " .. url)
  print(link)
  if link == nil then
    print("No link generated")
    return
  end
  -- Remove the trailing new line
  link = string.gsub(link, "\n$", "")
  print(link)

  -- Set the new line as the link
  vim.api.nvim_set_current_line(link)
end

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
  cmd = cmd .. notes_dir .. current_buffer .. "2>/dev/null"

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

function Insert_notes_link_alacritty_fzf()
  -- Make a temp file
  local tmp = Shell("mktemp")
  if tmp == nil then
    return
  end
  tmp = string.sub(tmp, 1, -2)

  local start_dir = Dirname(vim.api.nvim_buf_get_name(0))

  -- Run the script in alacritty
  local cmd = "~/.local/scripts/python/notes/make_link_fzf.py "
  cmd = cmd .. "--output-file " .. "'" .. tmp .. "'"
  cmd = cmd .. " --start-dir " .. "'" .. start_dir .. "'"
  local _ = Shell("alacritty -T popup -e " .. cmd)

  -- Read the output of the file
  vim.cmd([[ r ]] .. tmp)

  -- remove the tmp file
  Shell("rm " .. tmp)
end

-- Search Notes using ai-tools with fzf
-- and open note in neovim
-- TODO thoughts, how to make open in vim as well?
--      caching to disk is not very elegant
function Search_notes_fzf()
  -- Run the script in alacritty
  local cmd = "ai-tools live-search --fzf --editor 'code'"
  local _ = Shell("alacritty -T popup -e " .. cmd)
end

--------------------------------------------------------------------------------
-- Generate a Navigation Tree --------------------------------------------------
--------------------------------------------------------------------------------
function Generate_navigation_tree()
  -- Build the command
  local HOME = Get_HOME()
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local notes_dir = Get_dirname_buffer()

  local cmd = "~/.local/scripts/python/notes/generate-navigation.py "
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

--------------------------------------------------------------------------------
-- Insert an image from the clipboard --------------------------------------
--------------------------------------------------------------------------------

-- /home/ryan/.local/scripts/python/wm__clipboard.py
--[[
This function takes an image from the clipboard and aves it to ./assets
--]]
function Paste_png_image()
  local md_link = Shell("~/.local/scripts/python/wm__image-save.py assets")
  -- strip trailing
  if md_link == nil then
    print("No image found in clipboard")
  end
  md_link = string.gsub(md_link, "\n", "")
  require('notify')("Image saved to assets" .. md_link)
  vim.api.nvim_put({ md_link }, "l", true, true)
end

--------------------------------------------------------------------------------
-- Attach a File Into a Markdown Note ------------------------------------------
--------------------------------------------------------------------------------
function Attach_file()
  -- Prompt for filepath
  local filepath = vim.fn.input("Enter the filepath to attach: ")

  -- Create Directory if needed
  local dir = "assets/" -- NOTE Requires trailing /
  if vim.fn.isdirectory(dir) == 0 then
    print("Created Directory: " .. dir)
    vim.fn.mkdir(dir)
  end

  -- Copy file
  Shell("cp " .. filepath .. " " .. dir)
  print("Attached " .. filepath .. "into " .. dir)

  -- Insert Attachment Link
  local basename = vim.fn.fnamemodify(filepath, ":t")
  local line = dir .. basename
  line = "[" .. basename .. "](" .. line .. ")"
  vim.api.nvim_put({ line }, "l", true, true)
end

--------------------------------------------------------------------------------
-- Navigate Markdown Code Cells ------------------------------------------------
--------------------------------------------------------------------------------
function SlimeChunk()
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]

  local start_line, end_line = nil, nil

  -- Loop backwards for the start of the code block
  for i = current_line, 1, -1 do
    if lines[i]:match("^```") then
      start_line = i + 1 -- Don't include fence
      break
    end
  end


  -- Search forward for the end of the code block
  for i = current_line, #lines do
    if lines[i]:match("^```") then
      end_line = i - 1 -- don't include fence
      break
    end
  end

  if start_line == nil or end_line == nil then
    print("No code block found")
    return
  end

  -- Move the cursor to the start
  api.nvim_win_set_cursor(0, { start_line, 0 })
  -- Highlight
  vim.cmd('normal! V')
  -- Highlight down
  api.nvim_win_set_cursor(0, { end_line, 0 })

  -- Move the cursor whence it came
  -- api.nvim_win_set_cursor(0, current_location)

  print("Code block found from line " .. start_line .. " to " .. end_line)

  -- vim.cmd([[SlimeSend]])
end

-- @function GetBlockLocations
-- @desc This function scans the current buffer and finds all code blocks that are delimited by ```.
-- It returns a table of start and end line numbers for each code block found. If an odd number of fences is found,
-- it adds `nil` to the end of the fences list as a placeholder and prints a warning message.
-- @param debug (boolean) Optional parameter that enables printing debug information about the code blocks found.
-- @return table A table where each element is another table with two elements: start line number and end line number of a code block.
function GetBlockLocations(debug)
  if debug == nil then
    debug = false
  end
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)

  local fences = {}
  local langs = {}
  -- Search forward for the end of the code block
  for i = 1, #lines do
    -- Append the line number
    local line = lines[i]

    -- Append the detected language
    if line:match("^```") then
      fences[#fences + 1] = i
      langs[#langs + 1] = nil
    end
  end


  -- At this stage we have a flat vector of {start, end, start, end ...}
  --[[
  for i = 1, #fences, 2 do
    print("Code block found from line " .. fences[i] .. " to " .. fences[i + 1])
  end
  --]]

  -- Now restructure to pairs {{start, end, lang}, {start, end, lang}, ...}
  local blocks = {}
  if #fences % 2 ~= 0 then
    print("Warning: Odd number of fences found")
    table.insert(fences, nil)
  end
  for i = 1, #fences, 2 do
    local start, finish = fences[i], fences[i + 1]
    local lang = Detect_language(lines[start])
    table.insert(blocks, { start, finish, lang })
  end

  if debug == true then
    -- Print those blocks
    for i = 1, #blocks do
      local lang = blocks[i][3]
      if lang == nil then
        lang = ""
      end
      print(lang .. " Code block " .. i .. " found from line " .. blocks[i][1] .. " to " .. blocks[i][2])
    end
  end

  return blocks
end

function Detect_language(line)
  local supported_langs = { "python", "r", "julia", "rust", "go", "sh", "fish", "lua", "javascript" }
  for _, lang in ipairs(supported_langs) do
    if line:find(lang, 1, true) ~= nil then
      return lang
    end
  end
  return nil
end

-- Move to the next code block
-- If previous is true, move to the previous code block
function Move_to_next_code_block(previous)
  if previous == nil then
    previous = false
  end
  -- Get the cursor location
  local api = vim.api

  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]


  local blocks = GetBlockLocations()
  if previous then
    blocks = Reverse(blocks)
  end

  for i = 1, #blocks do
    local start, finish = blocks[i][1], blocks[i][2]
    _ = finish

    -- If moving forward go to next start
    local is_near_block = current_line < start
    -- If moving back, go to the last start
    if previous then
      is_near_block = current_line > start
    end

    if is_near_block then
      api.nvim_win_set_cursor(0, { start + 1, 0 })
      return
    end
  end
end
