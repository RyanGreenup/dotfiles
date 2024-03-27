--------------------------------------------------------------------------------
-- Directories and Projects-----------------------------------------------------
--------------------------------------------------------------------------------


-- Better Directory change
local function shell(cmd)
  local handle = io.popen(cmd)
  if handle == nil then
    print("unable to open process for cmd: " .. cmd)
    return
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function choose_dir_fd()
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
  local cmd = "zoxide query -l | rofi -dmenu"
  local output = shell(cmd)

  if output == nil then
    print("No directory selected")
    return
  end

  -- Strip all training newline
  return string.gsub(output, "\n$", "")
end

function Change_dir_interactive()
  local dir = choose_dir()
  if dir == nil then
    print("No directory selected")
    return
  end
  vim.api.nvim_set_current_dir(dir)
  print("Changed to: " .. dir)
end
vim.cmd("command! ChangeDir lua Change_dir_interactive()")

