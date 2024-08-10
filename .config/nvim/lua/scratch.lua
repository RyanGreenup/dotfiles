--- Stream shell command output to buffer
---@param cmd string: The Command to run, e.g. "cat" or "python"
---@param args string[]: The arguments to pass to the command, e.g. "file.py"
local function stream_shell_command(cmd, args)
  -- Pause tracking undos
  -- TODO put in function
  vim.o.undofile = false
  local uv = vim.loop

  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  print("stdin", stdin)
  print("stdout", stdout)
  print("stderr", stderr)


  local handle, pid = uv.spawn("python", {
    args = args, stdio = { stdin, stdout, stderr }
  }, function(code, signal) -- on exit
    print("exit code", code)
    print("exit signal", signal)
  end)

  print("process opened", handle, pid)

  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    -- todo let's call data text as it's a string
    if data then
      local text_list = { data }
      -- check if data has a newline
      if data:find("\n") then
        text_list = vim.split(data, "\n")
      end
      -- TODO arrrgh
      for _, t in ipairs(text_list) do
        vim.schedule(function()
          -- vim.api.nvim_buf_set_lines(0, current_line, current_line + 1, false, { data })
          if t ~= "" then
            vim.api.nvim_put({ data }, "c", true, true)
          else
            vim.api.nvim_put({ "" }, "l", true, true)
          end
        end)
      end
      print("stdout chunk", stdout, data)
    else
      print("stdout end", stdout)
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
    uv.close(handle, function()
      print("process closed", handle, pid)
    end)
  end)


  -- fn_1: https://www.reddit.com/r/neovim/comments/ulx17m/using_nvim_buf_set_text_without_running_into/
  -- Resume tracking undos
  vim.o.undofile = true
end

local function get_visual_lines()
  -- Get the start and end line numbers of the current visual selection
  local start_line = vim.fn.getpos("v")[2] - 1
  local end_line = vim.fn.getcurpos()[2] - 1

  -- Retrieve the lines between start_line and end_line (inclusive)
  local selected_lines = vim.fn.getline(start_line, end_line)
end

local function my_copilot()
  local line = vim.api.nvim_get_current_line()
  -- Move down a line
  -- vim.cmd [[<Esc>o<Esc>]]
  stream_shell_command("python", { "/tmp/tmp.CvM0e2ZWPI/file.py", line })
end

print(get_visual_lines())

-- my_copilot()


