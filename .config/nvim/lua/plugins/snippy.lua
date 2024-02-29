-- A function to toggle between normal and auto snippets for LaTeX
-- This is achieved by swapping the symlink target of the base snippet file
-- between the normal and auto snippet files.
-- This is a workaround for the poor performance of VimTeX highlighting that
-- would otherwise provide auto zones for snippets.

-- Toggle snippets
local vimfn = vim.fn
local print = print

local function get_home_path(path)
  return vimfn.expand("$HOME") .. path
end

local snippet_paths = {
  base = get_home_path("/.config/nvim/snippets/tex.snippets"),
  normal = get_home_path("/.config/nvim/snippets/tex_normal"),
  auto = get_home_path("/.config/nvim/snippets/tex_auto"),
}

local function debug_print(condition, message)
  if condition then
    print(message)
  end
end

local function get_symlink_target(symlink_path)
  local symlink_target = vimfn.resolve(symlink_path)
  debug_print(symlink_target ~= "", "Symlink target of " .. symlink_path .. " is " .. symlink_target)
  return symlink_target
end

local function is_known_symlink_target(symlink_target, known_targets)
  local is_known_target = false
  for _, target in ipairs(known_targets) do
    if symlink_target == target then
      is_known_target = true
      break
    end
  end
  debug_print(is_known_target, "Symlink target matches with a known target.")
  return is_known_target
end

local function swap_symlink(symlink_path, symlink_target, targets)
  local current_target_index = (symlink_target == targets[1]) and 2 or 1
  local success, errmsg = os.remove(symlink_path)
  if success then
    success, errmsg = os.execute(string.format('ln -s %s %s', targets[current_target_index], symlink_path))
    debug_print(success, "Successfully swapped symlink target to " .. targets[current_target_index])
  end
  if not success then
    print("Failed to swap symlink target. Reason: " .. errmsg)
  end
end

function rename_markdown_auto_snippets()
  -- Toggle markdown_auto.snippets by removing the extension
  local auto_file_name_disabled = "markdown_auto"
  local auto_file_name_enabled = "markdown_auto.snippets"

  -- Get the foll path
  local auto_file_name_enabled = get_home_path("/.config/nvim/snippets/" .. auto_file_name_enabled)
  local auto_file_name_disabled = get_home_path("/.config/nvim/snippets/" .. auto_file_name_disabled)

  -- Check if the snippets file exists
  local auto_snippet_exists = vimfn.filereadable(auto_file_name_enabled) == 1

  -- If so rename it
  if auto_snippet_exists then
    os.rename(auto_file_name_enabled, auto_file_name_disabled)
    print("Moved " .. auto_file_name_enabled .. " to " .. auto_file_name_disabled)
  else
  -- If not rename it back
    os.rename(auto_file_name_disabled, auto_file_name_enabled)
    print("Moved " .. auto_file_name_disabled .. " to " .. auto_file_name_enabled)
  end
end

function Snippy_Toggle_Auto()
  local symlink_target = get_symlink_target(snippet_paths.base)
  if is_known_symlink_target(symlink_target, { snippet_paths.normal, snippet_paths.auto }) then
    swap_symlink(snippet_paths.base, symlink_target, { snippet_paths.normal, snippet_paths.auto })
  end
  rename_markdown_auto_snippets()
  vim.cmd [[ :SnippyReload ]]
end
