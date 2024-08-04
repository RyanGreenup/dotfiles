local M = {} -- define a table to hold our module

-- NOTE Adapted from the source of slime.vim

local function identify_current_markdown_cell()
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]
  local lang = nil
  local context_path = "nvim_my_babel_context"
  local cell_path = "nvim_my_babel_cell"
  local start_line, end_line = nil, nil

  -- Loop backwards for the start of the code block
  for i = current_line, 1, -1 do
    local line = lines[i]
    if line:match("^```") then
      start_line = i + 1 -- Don't include fence
      lang = get_lang(line)
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

  return { start_line = start_line, end_line = end_line, lang = lang }
end


---Run a shell command and capture the output
---@param cmd string
---@return string
local function shell(cmd)
  print(cmd)
  local handle = io.popen(cmd)
  if handle == nil then
    print("Failed to run the command.")
  else
    local output = handle:read("*a")
    handle:close()
    return output
  end
end

local function get_zellij_sessions()
  local zellij_out = shell("zellij list-sessions -n")
  -- Split into a table
  local sessions = vim.split(zellij_out, "\n")
  -- Remove empty lines
  sessions = vim.tbl_filter(function(line)
    local allowed = true
    allowed = allowed and line ~= ""
    return line ~= ""
  end, sessions)
  -- Remove all text before first space
  for i, line in ipairs(sessions) do
    sessions[i] = vim.split(line, " ")[1]
  end
  -- print(vim.inspect(out))
  return sessions
end

local function session_exists(session)
  local sessions = get_zellij_sessions()
  for _, s in ipairs(sessions) do
    if s == session then
      return true
    end
  end
  return false
end

local function create_session_if_needed(session)
  if not session_exists(session) then
    shell("zellij -s " .. session)
  end
end

local function zellij_write_chars_cmd(session, text)
  return "zellij -s " .. session .. " action write-chars " .. [[']] .. text .. [[']]
end

local function escape_single_quotes(text)
  return text:gsub("'", "'\\''")
end

local function escape(text)
  local out = escape_single_quotes(text)
  return out
end

local function zellij_send(session, text, bracketed_paste)
  if bracketed_paste == nil then
    bracketed_paste = false
  end
  local text_to_send = escape(text) .. "\n"
  create_session_if_needed(session)
  if bracketed_paste then
    shell("zellij -s " .. session .. " action write " .. "27 91 50 48 48 126")
  end
  shell(zellij_write_chars_cmd(session, text_to_send))
  if bracketed_paste then
    shell("zellij -s " .. session .. " action write " .. "27 91 50 48 48 126")
  end
end

local function zellij_send_range(session, start, stop)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, start, stop, false)
  -- join the lines by newline
  local text = table.concat(lines, "\n")
  zellij_send(session, text)
end

local function zellij_send_line(session)
  local line = vim.api.nvim_get_current_line()
  zellij_send(session, line)
end

local function zellij_send_selection(session)
  local start = vim.fn.getpos("'<")[2] - 1
  local stop = vim.fn.getpos("'>")[2] - 1
  zellij_send_range(session, start, stop)
end

-- Define the function we want to export
function M.Zellij_send_range(session, start, stop)
  zellij_send_range(session, start, stop)
end

function M.Zellij_send_line(session)
  zellij_send_line(session)
end

function M.Zellij_send_selection(session)
  zellij_send_selection(session)
end

function M.zellij_send_markdown_cell()
  local current_cell = identify_current_markdown_cell()
  local first_line_num = current_cell.start_line
  local last_line_num = current_cell.end_line
  local lang = current_cell.lang
  zellij_send_range(lang, first_line_num - 1, last_line_num)
end

-- Return the module table so that it can be required by other scripts
return M
