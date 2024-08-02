local M = {} -- define a table to hold our module

-- @param fence_line string: The line containing the fence
local function get_lang(fence_line)
  -- Sort langs by length so that we match the longest first
  local langs = {
    "rs",
    "lua",
    "py",
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

local function get_sourcing_command(lang, file_path)
  -- py_command = "from " .. file_path .. " import *"
  local py_command = ""
  py_command = py_command .. "import contextlib\n"
  py_command = py_command .. "with contextlib.redirect_stdout(None):\n"
  py_command = py_command .. "    from " .. file_path .. " import *\n"
  local r_command = ""
  r_command = r_command .. 'invisible(suppressMessages({\n'
  r_command = '  ' .. r_command .. 'invisible(suppressWarnings({\n'
  r_command = '    ' .. r_command .. "original_channel <- stdout()\n"
  r_command = '    ' .. r_command .. 'sink("/dev/null")\n'
  r_command = '    ' .. r_command .. "source('" .. file_path .. ".r')\n"
  r_command = '    ' .. r_command .. "sink(original_channel)\n"
  r_command = '  ' .. r_command .. '}))'
  r_command = r_command .. '}))'
  local commands = {
    r = r_command,
    py = py_command
  }

  return commands[lang] or nil
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

local function write_file(file_path, contents)
  local f = io.open(file_path, 'w')
  if f == nil then
    print("Could not open file")
    return nil
  end
  for _, line in ipairs(contents) do
    f:write(line .. '\n')
  end
  f:close()
end


local function get_executable(lang)
  local executables = {
    r = "Rscript",
    py = "python3",
    python = "python3",
    jl = "julia",
    lua = "lua",
    rs = "Rscript"
  }
  return executables[lang] or nil
end


local result_markers = { [[<!-- BEGIN_RESULTS -->]], [[<!-- END_RESULTS -->]] }

--@param n_lines number: How far ahead the output can be from the end of the
--                       the code block (default 4)
--@param start_line number: The start line of the code block
--@param end_line number: The end line of the code block
--@param lines table: The lines of the current buffer
--@param buf number: The buffer number
local function remove_last_output(n_lines, start_line, end_line, lines, buf)
  if n_lines == nil then
    n_lines = 4
  end
  -- +2 because we did -1 to be inside the code block
  for i = end_line + 2, end_line + n_lines do
    -- Read that line
    local line = lines[i]
    if line == nil then
      break
    end
    -- If it is a code fence give up
    if line:match("^```") then
      break
    elseif line == result_markers[1] then
      -- Delete until the next result marker
      for j = i, #lines do
        if lines[j] == result_markers[2] then
          vim.api.nvim_buf_set_lines(buf, i - 1, j, false, {})
          break
        end
      end
    end
  end
end


local function get_start_line_of_cell_at_cursor()
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


local function highlight_markdown_cell()
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]
  local lang = nil
  local context_path = "nvim_my_babel_context"
  local cell_path = "nvim_my_babel_cell"

  current_cell = get_start_line_of_cell_at_cursor()
  start_line = current_cell.start_line
  end_line = current_cell.end_line
  lang = current_cell.lang



  if start_line == nil or end_line == nil then
    print("No code block found")
    return
  end

  -- Collect those lines
  local code_lines = {}
  for i = start_line, end_line do
    table.insert(code_lines, lines[i])
  end

  -- Get the command to source the file
  cell_path = cell_path .. '.' .. lang
  local command = get_sourcing_command(lang, context_path)
  context_path = context_path .. '.' .. lang
  if command == nil then
    print(lang .. " Not Yet Supported, No source() function implemented")
    return
  end


  -- Write the context lines
  local blocks = get_block_locations()
  local context_lines = {}
  for _, block in ipairs(blocks) do
    local block_start_line, block_end_line, block_lang = block[1], block[2], block[3]
    -- don't include the fence
    block_start_line = block_start_line + 1
    block_end_line = block_end_line - 1
    -- TODO Only include blocks less than the current line
    if block_lang == lang then
      for i = block_start_line, block_end_line do
        -- don't include the current cell or lines after
        if block_start_line < start_line then
          table.insert(context_lines, lines[i])
        end
      end
    end
  end
  write_file(context_path, context_lines)


  -- Write the cell lines
  local cell_lines = {}
  table.insert(cell_lines, command)
  for i = start_line, end_line do
    table.insert(cell_lines, lines[i])
  end
  write_file(cell_path, cell_lines)

  -- Move below the current cell
  vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })

  -- Remove the old output
  remove_last_output(4, start_line, end_line, lines, buf)

  -- Run the command
  local exe = get_executable(lang)
  if exe == nil then
    print("No executable found for " .. lang)
    return
  end
  -- just use vim.cmd
  --[[
  local handle = io.popen(exe .. " " .. cell_path)
  local result = nil
  if handle ~= nil then
    result = handle:read("*a")
    -- strip new line
    -- result = result:gsub("\n", "")
    handle:close()
  end
  if result == nil then
    print("Unable to get output from " .. exe .. " " .. cell_path)
    return
  end
  --]]


  -- Insert some text
  -- vim.api.nvim_put({ "```", result, "```" }, "l", , true)
  vim.api.nvim_put({ "", result_markers[1], "```" }, "l", true, true)
  vim.cmd('r! ' .. exe .. ' ' .. cell_path)
  vim.api.nvim_put({ "```", result_markers[2] }, "l", true, true)



  -- Remove the files
  os.remove(context_path)
  os.remove(cell_path)

  -- vim.cmd('split')
  -- vim.cmd('edit ' .. context_path)
  --
  -- vim.cmd('split')
  -- vim.cmd('edit ' .. cell_path)
  -- Restore the cursor position
  -- vim.api.nvim_win_set_cursor(0, current_location)
end


-- Define the function we want to export
function M.send_code()
  highlight_markdown_cell()
end

function M.remove_last_output()
  local current_cell = get_start_line_of_cell_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local start_line = current_cell.start_line
  local end_line = current_cell.end_line
  local lang = current_cell.lang
  remove_last_output(4, start_line, end_line, lines, buf)
end

-- Return the module table so that it can be required by other scripts
return M
