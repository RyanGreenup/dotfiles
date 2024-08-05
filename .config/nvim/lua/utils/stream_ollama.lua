local M = {} -- define a table to hold our module



---This function takes in text and puts it into the buffer after the cursor
---
---Unlike vim.api.nvim_put({text}, "c", ... )
---    This handles new lines
---Unlike vim.api.nvim_put({text}, "c", ... )
---    This does not leave a trailing new line in the buffer
---
---This is useful for streaming text that may have new lines
---@param data string: The input string, represents a chunk e.g. `def main():    print(foo)`
local function put_text_with_new_lines(data)
  if data.find(data, "\n") ~= nil then
    -- Split out the new lines
    local text_lines = vim.split(data, "\n")
    for i, text in ipairs(text_lines) do
      vim.schedule(function()
        vim.api.nvim_put({ text }, "c", true, true)
        if i ~= #text_lines then
          vim.api.nvim_put({ "" }, "l", true, false)
        end
      end)
    end
  else
    vim.schedule(function()
      vim.api.nvim_put({ data }, "c", true, true)
    end)
  end
end


--- Stream shell command output to buffer
---@param cmd string: The Command to run, e.g. "cat" or "python"
---@param args string[]: The arguments to pass to the command, e.g. "file.py"
local function stream_shell_command(cmd, args, verbose)
  if verbose == nil then
    verbose = false
  end
  -- Pause tracking undos
  -- TODO put in function
  vim.o.undofile = false
  local uv = vim.loop

  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  if verbose then
    print("stdin", stdin)
    print("stdout", stdout)
    print("stderr", stderr)
  end


  local handle, pid = uv.spawn(cmd, {
    args = args, stdio = { stdin, stdout, stderr }
  }, function(code, signal) -- on exit
    print("exit code", code)
    print("exit signal", signal)
  end)

  print("process opened", handle, pid)

  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    ---@type string data
    if data then
      put_text_with_new_lines(data)
    end
  end)

  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      print("stderr chunk", stderr, data)
    else
      print("stderr end", stderr)
    end
  end)

  uv.write(stdin, "Hello World")

  uv.shutdown(stdin, function()
    print("stdin shutdown", stdin)
    -- TODO how to handle nil?
    uv.close(handle, function()
      print("process closed", handle, pid)
    end)
  end)

  -- fn_1: https://www.reddit.com/r/neovim/comments/ulx17m/using_nvim_buf_set_text_without_running_into/
end

---Get the indeces for visually selected text
---@return integer[]: A tuple with the start and end line of visually selected lines, from top to bottom
local function get_visual_start_end()
  -- Get the start and end line numbers of the current visual selection
  local start_line = vim.fn.getpos("v")[2] - 1
  local end_line = vim.fn.getcurpos()[2] - 1

  -- Retrieve the lines between start_line and end_line (inclusive)
  -- Ensure that start_line is less than end_line (this matters if user selected upwards)
  if end_line < start_line then
    start_line, end_line = end_line, start_line
  end

  return { start_line, end_line }
end


--- Returns the visually selected lines and the end location of those lines
---@return string: The visually selected lines
local function get_lines_as_string(start_line, end_line)
  -- TODO handle selections that aren't linewise
  local selected_lines = vim.fn.getline(start_line, end_line)

  if type(selected_lines) == "string" then
    selected_lines = { selected_lines }
  end

  return table.concat(selected_lines, "\n")
end

--- Emulate the os.path.expanduser function from Python.
---@param path string
---@return string
local function expanduser(path)
  local home = os.getenv("HOME")
  if home == nil then
    -- use plenary if needed
    home = require("plenary.path").new({ "~" }):expand()
  end
  local fixed_path, _ = path:gsub("^~", home)
  return fixed_path
end

-- TODO not working
local function my_copilot_current_line(clobber, model, host)
  if clobber == nil then
    clobber = false
  end

  local line = vim.api.nvim_get_current_line()
  -- Move down a line
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  if clobber then
    vim.api.nvim_buf_set_lines(0, current_line, current_line + 1, false, { "" })
  else
    -- TODO handle buffer of limited length
    vim.api.nvim_win_set_cursor(0, { current_line + 1, 0 })
  end
  stream_shell_command("python", { "~/.local/scripts/python/ollama_stream-message.py", line, model, host })
end



local function my_copilot_current_selection(model, host)
  local indices = get_visual_start_end()
  local start_line, end_line = indices[1], indices[2]
  local content = get_lines_as_string(start_line, end_line)

  -- Add a new line
  vim.cmd [[normal jjo]]
  stream_shell_command("python", { expanduser("~/.local/scripts/python/ollama_stream-message.py"), content, model, host })
end


--------------------------------------------------------------------------------
-- Exports ---------------------------------------------------------------------
--------------------------------------------------------------------------------



-- Define the function we want to export
function M.stream_selection_to_ollama(model, host)
  if model == nil then
    model = "phi3:latest"
  end
  if host == nil then
    host = "localhost"
  end
  my_copilot_current_selection(model, host)
end

-- TODO add error messages
--      if the model isn't on the server this fails
--      if the server isn't available this fails
-- The loop should provide feedback in that case
-- Their should also be a ping to check all is well

-- Return the module table so that it can be required by other scripts
return M
