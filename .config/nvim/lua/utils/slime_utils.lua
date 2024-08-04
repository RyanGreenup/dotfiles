local M = {} -- define a table to hold our module

local function get_session_name(lang)
  local sessions = {
    r = "r",
    py = "ipython",
    python = "ipython",
    jl = "julia",
    lua = "lua",
    rs = "ipython"
  }
  return "slime_" .. sessions[lang] or nil
end


local function slime_send_range(start_num, end_num)
  vim.api.nvim_call_function("slime#send_range", { start_num, end_num })
end

local function slime_send_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local start_line = 1
  local end_line = #lines
  slime_send_range(start_line, end_line)
end

--- Changes the slime target pane based on the language
--- Returns the previous config
local function slime_change_lang(lang)
  -- change the slime target pane
  -- TODO create a map of languages to tmux sessions
  local current_slime = vim.b.slime_config
  local socket = "default"
  if current_slime ~= nil then
    local current_socket = current_slime["socket_name"]
    if current_socket ~= nil then
      socket = current_socket
    end
  end
  vim.b.slime_config = {
    socket_name = socket, target_pane = get_session_name(lang) }

  return current_slime
end

local function send_slime_markdown_cell()
  local current_cell = require('utils/markdown_code_cells').get_current_markdown_cell()
  -- don't cent codeblocks without a language
  if current_cell.lang == nil then
    return
  end

  -- change slime language
  local current_slime = slime_change_lang(current_cell.lang)

  -- Send the range
  slime_send_range(current_cell.start_line, current_cell.end_line)

  -- Restore slime
  -- if current_slime ~= nil then
  vim.b.slime_config = current_slime
  -- end
end

local function send_all_markdown_cells()
  local blocks = require('utils/markdown_code_cells').get_block_locations()
  local current_location = vim.api.nvim_win_get_cursor(0)
  for _, block in ipairs(blocks) do
    -- move to that location
    -- TODO check this isn't an OBOB
    vim.api.nvim_win_set_cursor(0, { block[1] + 1, 0 })
    -- send the block
    send_slime_markdown_cell()
  end
  -- restore the cursor
  vim.api.nvim_win_set_cursor(0, current_location)

  print("All Cells Evaluated with Slime")
end


-- Exports
function M.send_slime_markdown_cell()
  send_slime_markdown_cell()
end

function M.send_all_markdown_cells()
  send_all_markdown_cells()
end

function M.send_next_markdown_cell()
  require('utils/markdown_code_cells').Go_next_code_block()
  send_slime_markdown_cell()
end

function M.send_prev_markdown_cell()
  require('utils/markdown_code_cells').Go_prev_code_block()
  send_slime_markdown_cell()
end

function M.slime_send_buffer()
  slime_send_buffer()
end

function M.get_session_name(lang)
  return get_session_name(lang)
end


-- Return the module table so that it can be required by other scripts
return M
