require("utils/config")

--------------------------------------------------------------------------------
-- Directories and Projects-----------------------------------------------------
--------------------------------------------------------------------------------
-- Better Directory change
function Shell(cmd)
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
  local output = Shell(cmd)
  return home .. "/" .. output
  --]]
end

function choose_dir()
  -- Using Zoxide
  local cmd = "zoxide query -l | rofi -dmenu"
  local output = Shell(cmd)

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


-- Change to the directory of the notes as defined by the
-- Get_notes_dir function
function CD_notes()
  local notes_dir = Get_notes_dir()
  vim.api.nvim_set_current_dir(notes_dir)
  print("Changed to: " .. notes_dir)
end

-- Change to the directory of the current buffer
--
-- Why a Function?
-- ---------------
-- This is wrapped into a function because I'm unsure
-- If I want to do this sometimes, it may be simpler to manage
-- manually with `SPC f g`.
-- If I change my mind, I can `grep` for the function name
function CD_current_buffer()
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local current_dir, _ = Dirname(current_file_path)
  print(current_dir)
  vim.api.nvim_set_current_dir(current_dir)
end

-- Returns the directory of the current buffer as a string
function Get_dirname_buffer()
  local current_file_path = vim.api.nvim_buf_get_name(0)
  local current_dir, _ = Dirname(current_file_path)
  return current_dir
end

-- TODO
function Choose_journal()
  -- local cmd = "fd md " .. HOME .. "/Notes/slipbox/journals | tac | rofi -dmenu"
  -- local cmd = "ls -t " .. Get_notes_dir() .. "/journals " .. " | " .. " rofi -dmenu"
  local dir = Get_notes_dir() .. "/journals"
  local cmd = "ls -t " .. dir .. " | " .. " rofi -dmenu"
  local output = dir .. "/" .. Shell(cmd)

  if output == nil then
    print("No File Selected")
    return
  end

  -- Strip all training newline
  Open_file_in_split(output, "")
end

vim.cmd("command! ChooseJournal lua Choose_journal()")
