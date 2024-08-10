local M = {} -- define a table to hold our module

-- @param fence_line string: The line containing the fence
local function get_lang(fence_line)
  -- Sort langs by length so that we match the longest first
  local langs = {
    "rs",
    "lua",
    "py",
    "python",
    "rust",
    "julia",
    "sh",
    "fish",
    "jl",
    "r",
  }


  for _, lang in ipairs(langs) do
    if fence_line:find(lang, 1, true) ~= nil then
      return lang
    end
  end
  return nil
end

local function get_tresitter_type()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local buf_num = 0 -- your buffer number (replace with appropriate value)
  local root_node = ts_utils.get_node_at_cursor(0)
  if root_node == nil then
    return nil
  end
  local type = root_node:type()
  print(type)
  return type
end


--- Detect a code fence
local function is_code_fence(lines, i, use_treesitter)
  -- TODO switch to tresitter?
  if use_treesitter == nil then
    use_treesitter = false
  end
  if use_treesitter then
    local current_location = vim.api.nvim_win_get_cursor(0)
    -- Move cursor to the beginning of the line
    vim.api.nvim_win_set_cursor(0, {i, 0 })
    -- Move cursor forward to first non-whitespace character
    vim.cmd("normal! ^")
    local ts_type = get_tresitter_type()
    -- Move cursor back
    vim.api.nvim_win_set_cursor(0, current_location)
    if ts_type ~= nil then
      return ts_type == "fenced_code_block_delimiter"
    else
      local line = lines[i]
      return line:match("^```") ~= nil
    end
  end
end

local function get_current_markdown_cell()
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]
  local lang = nil
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

-- @function GetBlockLocations
-- @desc This function scans the current buffer and finds all code blocks that are delimited by ```.
-- It returns a table of start and end line numbers for each code block found. If an odd number of fences is found,
-- it adds `nil` to the end of the fences list as a placeholder and prints a warning message.
-- @param debug (boolean) Optional parameter that enables printing debug information about the code blocks found.
-- @return table A table where each element is another table with two elements: start line number and end line number of a code block.
local function get_block_locations(debug)
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
    local lang = get_lang(lines[start])
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

-- Move to the next code block
-- If previous is true, move to the previous code block
local function Move_to_next_code_block(previous)
  if previous == nil then
    previous = false
  end

  print("here")
  -- Get the cursor location
  local api = vim.api

  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]


  local blocks = get_block_locations()
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
      -- If within 5 lines of the block, assume the user
      -- wants to go to the previous block
      is_near_block = current_line > (start + 5)
    end

    if is_near_block then
      api.nvim_win_set_cursor(0, { start + 1, 0 })
      return
    end
  end
end

-- Maps a language to a tmux session


-- Define the function we want to export

function M.get_current_markdown_cell()
  return get_current_markdown_cell()
end

function M.Go_next_code_block()
  Move_to_next_code_block()
end

function M.Go_prev_code_block()
  Move_to_next_code_block(true)
end

function M.get_lang(fence_line)
  return get_lang(fence_line)
end

function M.get_block_locations()
  return get_block_locations()
end

-- Return the module table so that it can be required by other scripts
return M
