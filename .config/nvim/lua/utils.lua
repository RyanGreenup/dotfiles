--------------------------------------------------------------------------------
-- Markdown Stuff --------------------------------------------------------------
--------------------------------------------------------------------------------


--[[
Changes a timestamp in a given line from a day planner file by adding the specified number of minutes.
  @param line String containing the line from which the timestamp should be changed.
  @param minutes Number of minutes to add to the existing timestamp. Can be negative to subtract.
  @param delay Optional boolean flag indicating whether the starting time also needs to be updated. Default is false.
  @return New line with the updated timestamp.

  Example:
  change_dayplanner_time("- [ ] 10:00 - 11:00 mdbook", 30) -> "- [ ] 10:30 - 11:30 mdbook"
  change_dayplanner_time("- [ ] 10:00 - 11:00 mdbook", 30, true) -> "- [ ] 10:00 - 11:30 mdbook"
]]
--
local function change_dayplanner_time(line, minutes, delay)
  delay = delay or false
  local start_time, end_time = string.match(line, "(%d%d:%d%d) %- (%d%d:%d%d)")

  -- If start_time, end_time not found, return original line
  if not (start_time and end_time) then return line end

  local function inc_time(time, minutes)
    local hours, mins = string.match(time, "(%d+):(%d+)")
    hours = tonumber(hours)
    mins = tonumber(mins)

    local time_in_minutes = hours * 60 + mins + minutes
    local new_hours = math.floor(time_in_minutes / 60) % 24
    local new_mins = time_in_minutes % 60

    return string.format("%02d:%02d", new_hours, new_mins)
  end

  -- Get new times
  local new_end_time = inc_time(end_time, minutes)
  local new_start_time = start_time
  if not delay then
    new_start_time = inc_time(start_time, minutes)
  end

  -- Can't have end time before start time
  if new_end_time < new_start_time then
    new_end_time = new_start_time
    print("End time cannot be before start time")
  end

  -- Replace the times in the line
  local new_line = string.gsub(line, start_time .. " %- " .. end_time, new_start_time .. " - " .. new_end_time)

  return new_line
end

local function add_time_stamp(s)
  local checkbox = '- [ ]'
  local timestamp = ""
  -- Check if the line has a "^- [ ] "
  local pattern = "^%- %[%s%]"
  -- If it does remove it and we'll add it back later
  if string.match(s, pattern) then
    checkbox = string.sub(s, 1, 6)
    s = string.sub(s, 7)
  end

  -- Check if the line has a "^- [ ] 00:00 - 00:00"
  local pattern = "^%d%d:%d%d %- %d%d:%d%d"
  if not string.match(s, pattern) then
    local hours = tonumber(os.date("%H"))
    local mins = tonumber(os.date("%M"))
    local delta = 30

    local time_in_minutes = hours * 60 + mins + delta
    local new_hours = math.floor(time_in_minutes / 60) % 24
    local new_mins = time_in_minutes % 60
    timestamp = string.format("%02d:%02d - %02d:%02d ", hours, mins, new_hours, new_mins)
  end

  -- return checkbox .. timestamp .. " " .. string.sub(s, 7)
  return checkbox .. timestamp .. "" .. s
end


function Sort_paragraph()
  -- Get the current buffer and cursor position
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- Get the line number of the end of the paragraph
  local end_line = vim.fn.search('^$', 'Wn') - 1

  -- If 'end' is less than 'start', set it to the last line of the current buffer
  if end_line < cursor[1] - 1 then
    end_line = vim.api.nvim_buf_line_count(buf) - 1
  end

  -- Get all lines from the cursor to the end of the paragraph
  local lines = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, end_line, false)

  -- Sort the lines
  table.sort(lines)

  -- Replace the original lines with the sorted ones
  vim.api.nvim_buf_set_lines(buf, cursor[1] - 1, end_line, false, lines)
end
-- Export as a command
vim.cmd("command! SortParagraph lua Sort_paragraph()")

function Change_dayplanner_line(delta_min, delay, sort)
  delay = delay or false
  sort = sort or false
  -- get line
  local line = vim.api.nvim_get_current_line()
  line = add_time_stamp(line)
  -- strip new lines
  line = string.gsub(line, "\n$", "")
  -- change time
  local new_line = change_dayplanner_time(line, delta_min, delay)
  -- set line
  vim.api.nvim_set_current_line(new_line)

  -- Finally Sort the paragraph
  if sort then
    Sort_paragraph()
  end

  if delta_min > 0 then
    print("+ " .. delta_min .. "m")
  else
    print("- " .. -1 * delta_min .. "m")
  end
end

function create_mermaid()
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
  vim.cmd("normal! \"*p")
end

--------------------------------------------------------------------------------
-- Directories and Projects-----------------------------------------------------
--------------------------------------------------------------------------------

-- Better Directory change
local function shell(cmd)
  local handle = io.popen(cmd)
  if handle == nil then
    print("unable to open process for cmd: " .. cmd)
    return
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function choose_dir_fd()
  local home = os.getenv("HOME")
  -- Using Find
  --[[
  local cmd = "cd " .. home
  cmd = cmd .. " && " .. "fd -t d .    | rofi -dmenu"
  local output = shell(cmd)
  return home .. "/" .. output
  --]]
end

local function choose_dir()
  -- Using Zoxide
  local cmd = "zoxide query -l | wofi -dmenu"
  local output = shell(cmd)

  if output == nil then
    print("No directory selected")
    return
  end

  -- Strip all training newline
  return string.gsub(output, "\n$", "")
end

local function change_dir_interactive()
  local dir = choose_dir()
  if dir == nil then
    print("No directory selected")
    return
  end
  vim.api.nvim_set_current_dir(dir)
end

function CD()
  change_dir_interactive()
end

--------------------------------------------------------------------------------
-- Modal Layer Keybindings -----------------------------------------------------------
--------------------------------------------------------------------------------

-- Here we define some functions to map to the arrow keys
-- These functions change depending on whether or not a "mode" has been
-- entered.
-- A mode is entered if the Mode variable is set to something
-- Which key has settings for this.

ModalLayer = {
  Organize = "Organize", -- Dayplanner adjustments on tasks
  Resize = "Resize",     -- Window Resizing
  Split = "Split",       -- Splitting windows
  Move = "Move",         -- Normal movement
  Buffer = "Buffer",
  Git = "Git",
  Search = "Search",
  None = "None",
}

Direction = {
  Up = "Up",
  Down = "Down",
  Left = "Left",
  Right = "Right",
}

local commands = {
  [ModalLayer.Organize] = {
    [Direction.Up] = function() Change_dayplanner_line(30) end,
    [Direction.Down] = function() Change_dayplanner_line(-30) end,
    [Direction.Left] = function() Change_dayplanner_line(-30, true) end,
    [Direction.Right] = function() Change_dayplanner_line(30, true) end,
  },
  [ModalLayer.Split] = {
    [Direction.Up] = function()
      vim.cmd("split"); vim.cmd("wincmd k"); vim.cmd("bp")
    end,
    [Direction.Down] = function()
      vim.cmd("split"); vim.cmd("wincmd j"); vim.cmd("bp")
    end,
    [Direction.Left] = function()
      vim.cmd("vsplit"); vim.cmd("wincmd h"); vim.cmd("bp")
    end,
    [Direction.Right] = function()
      vim.cmd("vsplit"); vim.cmd("wincmd l"); vim.cmd("bp")
    end,
  },
  [ModalLayer.Move] = {
    [Direction.Up] = function()
      vim.cmd("wincmd k"); Resize_windows_Golden()
    end,
    [Direction.Down] = function()
      vim.cmd("wincmd j"); Resize_windows_Golden()
    end,
    [Direction.Left] = function()
      vim.cmd("wincmd h"); Resize_windows_Golden()
    end,
    [Direction.Right] = function()
      vim.cmd("wincmd l"); Resize_windows_Golden()
    end,
  },
  [ModalLayer.Resize] = {
    [Direction.Right] = function() vim.cmd("vertical resize -5") end,
    [Direction.Left] = function() vim.cmd("vertical resize +5") end,
    [Direction.Down] = function() vim.cmd("resize -5") end,
    [Direction.Up] = function() vim.cmd("resize +5") end,
  },
  [ModalLayer.Buffer] = {
    [Direction.Up] = function() vim.cmd("bn") end,
    [Direction.Down] = function() vim.cmd("bp") end,
    [Direction.Left] = function() vim.cmd("bfirst") end,
    [Direction.Right] = function() vim.cmd("blast") end,
  },
  [ModalLayer.Git] = {
    [Direction.Up] = function() print("TODO git up") end,
    [Direction.Down] = function() print("TODO git down") end,
    [Direction.Left] = function() print("TODO git left") end,
    [Direction.Right] = function() print("TODO git right") end,
  },
}


function Up()
  commands[Mode][Direction.Up]()
end

function Down()
  commands[Mode][Direction.Down]()
end

function Left()
  commands[Mode][Direction.Left]()
end

function Right()
  commands[Mode][Direction.Right]()
end

function ChangeMode(mode)
  Mode = mode
end

Mode = ModalLayer.Organize










------------------------------------------------------------------------------
-- sort out








function get_recent_journal_files(dir_path)
  -- Get all .md files in the directory using vim.fn.globpath
  local files_string = vim.fn.globpath(dir_path, '*.md')

  -- Split the files string into a table with individual file names
  local file_list = vim.split(files_string, '\n')

  -- Filter the file names to match the date format
  local journal_files = {}
  for _, file in ipairs(file_list) do
    if file:match('%d%d%d%d%-%d%d%-%d%d%.md') then
      table.insert(journal_files, file)
    end
  end

  -- Sort the files in descending order
  table.sort(journal_files, function(a, b) return a > b end)

  -- Return the last 5 files
  -- return { unpack(journal_files, math.max(#journal_files - 4, 1)) }
  -- Return the first 5 files instead
  return { unpack(journal_files, 1, 5) }
end

-- Function to check if there is a split below

function is_split_below()
  local current_win = vim.api.nvim_get_current_win()

  -- Get the position [row, col] and height of the current window
  local _, current_col = unpack(vim.api.nvim_win_get_position(current_win))
  local current_bottom = select(2, unpack(vim.api.nvim_win_get_position(current_win))) +
      vim.api.nvim_win_get_height(current_win)

  -- Loop over all windows
  local all_wins = vim.api.nvim_list_wins()

  for _, win_id in ipairs(all_wins) do
    if win_id ~= current_win then
      -- Get the position [row, col] of the other window
      local _, win_col = unpack(vim.api.nvim_win_get_position(win_id))
      local win_top = select(2, unpack(vim.api.nvim_win_get_position(win_id)))

      -- Return true if another window begins at the same column and below the current window
      if win_col == current_col and win_top >= current_bottom then
        return true
      end
    end
  end
  return false
end

-- Function to resize the windows to golden ratio
function Resize_windows_Golden()
  local ratio = 0.618
  local width = vim.api.nvim_get_option('columns')
  local height = vim.api.nvim_get_option('lines')
  local new_width = math.floor(width * ratio)
  local new_height = math.floor(height * ratio)


  -- Check that there is a split below
  if is_split_below() then
    vim.api.nvim_command('resize ' .. new_height)
  end
  vim.api.nvim_command('vertical resize ' .. new_width)
end

function Open_journals()
  -- Get recent journal files and open them in neovim
  HOME = os.getenv('HOME')
  dir_path = HOME .. '/Notes/slipbox/journals'
  local files = get_recent_journal_files(dir_path)
  for i, file in ipairs(files) do
    print(file)
    -- if the file exists
    if vim.fn.filereadable(file) == 0 then
      goto continue
    end
    -- split
    -- if i is even
    if i % 2 == 0 then
      vim.api.nvim_command('vsplit ' .. file)
    else
      vim.api.nvim_command('split ' .. file)
    end
    -- Open the file
    vim.api.nvim_command('e ' .. file)
    -- If i is 1 and this is the first close the last window
    if i == 1 then
      vim.api.nvim_command('wincmd w')
      vim.api.nvim_command('q')
    else
      -- Resize the window (can't resize the first window)
      Resize_windows_Golden()
    end
    ::continue::
  end
end

--[[

Example

Open the file ~/Notes/linux.md

Take the current line and run this function:

/arch

That line will be replaced with:

[➡️ /linux](/linux.arch.md)

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
