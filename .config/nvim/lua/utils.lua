

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
function change_dayplanner_time(line, minutes, delay)
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

  -- Replace the times in the line
  local new_line = string.gsub(line, start_time .. " %- " .. end_time, new_start_time .. " - " .. new_end_time)

  return new_line
end

function Change_dayplanner_line(delta_min, delay)
  delay = delay or false
  -- get line
  local line = vim.api.nvim_get_current_line()
  local line = add_time_stamp(line)
  -- strip new lines
  line = string.gsub(line, "\n$", "")
  -- change time
  local new_line = change_dayplanner_time(line, delta_min, delay)
  -- -- set line
  vim.api.nvim_set_current_line(new_line)

  if delta_min > 0 then
    print("+ " .. delta_min .. "m")
  else
    print("- " .. -1 * delta_min .. "m")
  end
end

function add_time_stamp(s)
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


--------------------------------------------------------------------------------
-- Directories and Projects-----------------------------------------------------
--------------------------------------------------------------------------------

  -- Better Directory change
  function shell(cmd)
    local handle = io.popen(cmd)
    if handle == nil then
      print("unable to open process for cmd: " .. cmd)
      return
    end
    local result = handle:read("*a")
    handle:close()
    return result
  end

  function choose_dir_fd()
    local home = os.getenv("HOME")
    -- Using Find
    --[[
  local cmd = "cd " .. home
  cmd = cmd .. " && " .. "fd -t d .    | rofi -dmenu"
  local output = shell(cmd)
  return home .. "/" .. output
  --]]
  end

  function choose_dir()
    -- Using Zoxide
    local cmd = "zoxide query -l | wofi -dmenu"
    local output = shell(cmd)

    -- Strip all training newline
    return string.gsub(output, "\n$", "")
  end

  function change_dir_interactive()
    local dir = choose_dir()
    vim.api.nvim_set_current_dir(dir)
  end

  function CD()
    change_dir_interactive()
  end
