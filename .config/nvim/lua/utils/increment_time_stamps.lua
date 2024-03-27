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

--[[
Adds a timestamp to a line if it doesn't already have one.
  @param s String containing the line to which the timestamp should be added.
  @return Line with the timestamp added.

  Example:
  add_time_stamp("- [ ] mdbook") -> "- [ ] 10:00 - 11:00 mdbook"
  add_time_stamp("- [ ] 10:00 - 11:00 mdbook") -> "- [ ] 10:00 - 11:00 mdbook"
--]]
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


--[[
Sorts the lines of the current paragraph in ascending order.
  Example:
  Before:
  ```
  3
  1
  2
  ```

  After:
  ```
  1
  2
  3
  ```
]]
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

--[[
Changes the time of the current line in a day planner file by adding the specified number of minutes.
  @param delta_min Number of minutes to add to the existing timestamp. Can be negative to subtract.
  @param delay Optional boolean flag indicating whether the starting time also needs to be updated. Default is false.
  @param sort Optional boolean flag indicating whether the paragraph should be sorted after the time change. Default is false.
]]
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

