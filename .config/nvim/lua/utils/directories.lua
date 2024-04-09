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

function Get_HOME()
  local HOME = os.getenv("HOME")
  if HOME == nil then
    print("HOME not set")
    return
  end
  return HOME
end

function Get_notes_dir()
  return Get_HOME() .. "/Notes/slipbox"
end

-- TODO
function Choose_journal()
  -- local cmd = "fd md " .. HOME .. "/Notes/slipbox/journals | tac | rofi -dmenu"
  -- local cmd = "ls -t " .. Get_notes_dir() .. "/journals " .. " | " .. " rofi -dmenu"
  local dir = Get_notes_dir() .. "/journals"
  local cmd = "ls -t " .. dir .. " | " .. " rofi -dmenu"
  local output = dir .. "/" .. shell(cmd)

  if output == nil then
    print("No File Selected")
    return
  end

  -- Strip all training newline
  Open_file_in_split(output, "")
end
vim.cmd("command! ChooseJournal lua Choose_journal()")
