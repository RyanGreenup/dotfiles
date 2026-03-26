--- Date shifting for org-mode-style timestamps in markdown.
--- Increment or decrement date/time components under the cursor using S-Up/S-Down.
--- Handles month lengths, leap years, and hour/minute wrapping via os.time/os.date.
local M = {}

--- A parsed date found on a line, with its position metadata.
---@class orgmark.DateMatch
---@field year number
---@field month number
---@field day number
---@field hour number|nil
---@field minute number|nil
---@field date_start number  0-indexed column where the date pattern starts
---@field date_end number    0-indexed column past the end of the date pattern
---@field time_start number|nil  0-indexed column where HH:MM starts
---@field time_end number|nil    0-indexed column past the end of HH:MM
---@field has_time boolean

--- Find a date pattern on the given line text and return parsed components.
--- Looks for `YYYY-MM-DD` optionally followed by ` HH:MM`.
---@param line_text string  The line to search
---@return orgmark.DateMatch|nil match  Parsed date or nil if no date found
local function find_date_on_line(line_text)
  -- Search for a date with optional time: YYYY-MM-DD[ HH:MM]
  -- Try date+time first, then date-only
  local ds, de, y, mo, d, h, mi = line_text:find('(%d%d%d%d)%-(%d%d)%-(%d%d)%s+(%d%d):(%d%d)')
  if ds then
    -- Find the boundary of just the date portion (YYYY-MM-DD)
    local date_end = ds - 1 + 10 -- YYYY-MM-DD is 10 chars
    return {
      year = tonumber(y),
      month = tonumber(mo),
      day = tonumber(d),
      hour = tonumber(h),
      minute = tonumber(mi),
      date_start = ds - 1, -- convert to 0-indexed
      date_end = date_end, -- 0-indexed, points past last char of date
      time_start = de - 5, -- 0-indexed start of HH:MM (de is 1-indexed end)
      time_end = de, -- 0-indexed past end
      has_time = true,
    }
  end

  -- Date-only pattern
  ds, de, y, mo, d = line_text:find('(%d%d%d%d)%-(%d%d)%-(%d%d)')
  if ds then
    return {
      year = tonumber(y),
      month = tonumber(mo),
      day = tonumber(d),
      hour = nil,
      minute = nil,
      date_start = ds - 1,
      date_end = de,
      time_start = nil,
      time_end = nil,
      has_time = false,
    }
  end

  return nil
end

--- Determine which component of the date the cursor column falls on.
---@param match orgmark.DateMatch  The parsed date
---@param col number  0-indexed cursor column
---@return string component  One of 'year', 'month', 'day', 'hour', 'minute', or 'none'
local function component_at_col(match, col)
  local s = match.date_start
  -- YYYY: columns s..s+3
  if col >= s and col <= s + 3 then
    return 'year'
  end
  -- MM: columns s+5..s+6
  if col >= s + 5 and col <= s + 6 then
    return 'month'
  end
  -- DD: columns s+8..s+9
  if col >= s + 8 and col <= s + 9 then
    return 'day'
  end
  -- Hyphens: default to the nearest component
  -- s+4 is the first hyphen -> treat as month
  if col == s + 4 then
    return 'month'
  end
  -- s+7 is the second hyphen -> treat as day
  if col == s + 7 then
    return 'day'
  end
  -- Time components
  if match.has_time and match.time_start then
    local ts = match.time_start
    -- HH: ts..ts+1
    if col >= ts and col <= ts + 1 then
      return 'hour'
    end
    -- Colon at ts+2 -> treat as minute
    if col == ts + 2 then
      return 'minute'
    end
    -- MM: ts+3..ts+4
    if col >= ts + 3 and col <= ts + 4 then
      return 'minute'
    end
  end

  return 'none'
end

--- Apply a delta to a date component, using os.time for correct arithmetic.
--- Returns the new date components after the shift.
---@param match orgmark.DateMatch  The current date
---@param component string  Which component to shift
---@param delta number  +1 or -1 (for minutes, +5 or -5)
---@return orgmark.DateMatch new_match  Updated date components
local function shift_component(match, component, delta)
  local y, mo, d = match.year, match.month, match.day
  local h, mi = match.hour or 0, match.minute or 0

  if component == 'year' then
    y = y + delta
  elseif component == 'month' then
    mo = mo + delta
  elseif component == 'day' then
    d = d + delta
  elseif component == 'hour' then
    h = h + delta
  elseif component == 'minute' then
    mi = mi + (delta * 5)
  end

  -- Use os.time to normalise (handles overflow/underflow of all fields)
  local t = os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = 0 })
  local dt = os.date('*t', t)

  return {
    year = dt.year,
    month = dt.month,
    day = dt.day,
    hour = match.has_time and dt.hour or nil,
    minute = match.has_time and dt.min or nil,
    date_start = match.date_start,
    date_end = match.date_end,
    time_start = match.time_start,
    time_end = match.time_end,
    has_time = match.has_time,
  }
end

--- Format a DateMatch back into a string.
---@param match orgmark.DateMatch
---@return string date_str  The formatted date portion (YYYY-MM-DD)
---@return string|nil time_str  The formatted time portion (HH:MM) or nil
local function format_date(match)
  local date_str = string.format('%04d-%02d-%02d', match.year, match.month, match.day)
  local time_str = nil
  if match.has_time and match.hour and match.minute then
    time_str = string.format('%02d:%02d', match.hour, match.minute)
  end
  return date_str, time_str
end

--- Perform a date shift on the current line.
---@param delta number  +1 for increment, -1 for decrement
local function do_shift(delta)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if not line then
    return
  end

  local match = find_date_on_line(line)
  if not match then
    return
  end

  local component = component_at_col(match, col)
  if component == 'none' then
    -- Cursor is not on any date component; try defaulting to day
    -- if the cursor is anywhere within the date+time span
    local in_date = col >= match.date_start and col < match.date_end
    local in_time = match.has_time and match.time_start and col >= match.time_start and col < match.time_end
    if in_date then
      component = 'day'
    elseif in_time then
      component = 'minute'
    else
      return
    end
  end

  local new_match = shift_component(match, component, delta)
  local new_date, new_time = format_date(new_match)

  -- Replace the date portion in-place
  local before = line:sub(1, match.date_start)
  local after
  if match.has_time and match.time_end then
    after = line:sub(match.time_end + 1)
    line = before .. new_date .. ' ' .. (new_time or '') .. after
  else
    after = line:sub(match.date_end + 1)
    line = before .. new_date .. after
  end

  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })
  -- Keep cursor on same column
  vim.api.nvim_win_set_cursor(0, { row, col })
end

--- Increment the date/time component under the cursor.
--- Year/month/day shift by 1; minutes shift by 5.
function M.shift_up()
  do_shift(1)
end

--- Decrement the date/time component under the cursor.
--- Year/month/day shift by 1; minutes shift by 5.
function M.shift_down()
  do_shift(-1)
end

return M
