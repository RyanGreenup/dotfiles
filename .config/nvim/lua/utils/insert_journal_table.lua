local M = {} -- define a table to hold our module

local function get_month(date)
  return date:sub(1, 7)
end

local function build_table(before_date, after_date)
  return {
    "| [Yesterday]  |  [Month]  |  [Tomorrow] |",
    "|-------------|---------|------------|",
    "",
    "[Yesterday]: " .. "j_" .. before_date .. ".md",
    "[Tomorrow]: " .. "j_" .. after_date .. ".md",
    "[Month]: " .. "j_" .. get_month(before_date) .. ".md",
  }
end

-- Define the function we want to export
function M.Insert_journal_dates_nav()
  local filename = vim.fn.expand("%:t")
  print("Filename is " .. filename)
  -- Use string.match to find the date in the filename
  local pattern = "j_(%d%d%d%d[-]%d%d[-]%d%d)[.]md"
  local date = filename:match(pattern)

  if not date then
    print("File name is not in the correct format")
  end

  -- Convert the date string to a time object
  local year, month, day = date:match("(%d+)-(%d+)-(%d+)")
  local t = os.time { year = year, month = month, day = day }

  -- Subtract one day and add one day to the time object
  local before_t = t - 24 * 60 * 60
  local after_t = t + 24 * 60 * 60

  -- Convert the times back to date strings
  local before_date = os.date("%Y-%m-%d", before_t)
  local after_date = os.date("%Y-%m-%d", after_t)


  -- Insert the line
  local lines = build_table(before_date, after_date)
  vim.api.nvim_put(lines, "l", true, true)
end

function M.setup()
  -- Add a Vim command
  function Insert_journal_dates_nav()
    M.Insert_journal_dates_nav()
  end

  vim.cmd("command! InsertJournalTable lua require('utils/insert_journal_table').Insert_journal_dates_nav()")
end

-- Return the module table so that it can be required by other scripts
return M
