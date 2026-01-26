-- Symlink Paste Plugin for Yazi
-- Paste symlinks from Yazi's yank buffer with relative path calculation
-- Useful for symlink farms where sources are in different locations

local function log_debug(msg)
  ya.err("[symlink-paste] DEBUG: " .. msg)
end

local function resolve_symlink(path)
  local permit = ya.hide()
  local handle = io.popen("realpath \"" .. path .. "\" 2>/dev/null", "r")
  local result = ""
  if handle then
    result = string.gsub(handle:read("*all") or "", "^%s*(.-)%s*$", "%1")
    handle:close()
  end
  permit:drop()
  return result ~= "" and result or nil
end

local function is_symlink(path)
  local permit = ya.hide()
  local handle = io.popen("test -L \"" .. path .. "\" && echo true || echo false", "r")
  local result = ""
  if handle then
    result = string.gsub(handle:read("*all") or "", "^%s*(.-)%s*$", "%1")
    handle:close()
  end
  permit:drop()
  return result == "true"
end

local function get_relative_path(from_dir, to_path)
  local permit = ya.hide()
  local cmd = string.format("realpath --relative-to=\"%s\" \"%s\"", from_dir, to_path)
  local handle = io.popen(cmd .. " 2>/dev/null", "r")
  local result = ""
  if handle then
    result = string.gsub(handle:read("*all") or "", "^%s*(.-)%s*$", "%1")
    handle:close()
  end
  permit:drop()
  return result ~= "" and result or nil
end

local function file_exists(path)
  local permit = ya.hide()
  local handle = io.popen("test -e \"" .. path .. "\" && echo true || echo false", "r")
  local result = ""
  if handle then
    result = string.gsub(handle:read("*all") or "", "^%s*(.-)%s*$", "%1")
    handle:close()
  end
  permit:drop()
  return result == "true"
end

local function get_basename(path)
  return string.match(path, "[^/]*$")
end

local get_yanked_and_cwd = ya.sync(function(state)
  local yanked_list = {}

  for idx, url in pairs(cx.yanked) do
    local path = tostring(url)
    table.insert(yanked_list, path)
  end

  local cwd = tostring(cx.active.current.cwd)
  local is_cut = cx.yanked.is_cut
  local mode = is_cut and "CUT" or "YANK"

  log_debug("Found " .. #yanked_list .. " file(s) in " .. mode .. " mode, cwd: " .. cwd)

  return yanked_list, cwd, is_cut
end)

return {
  entry = function(self, args)
    log_debug("=== Starting symlink paste operation ===")

    local yanked_list, current_dir, is_cut = get_yanked_and_cwd()

    if #yanked_list == 0 then
      ya.err("No yanked files found")
      return
    end

    local success_count = 0
    local error_count = 0
    local skip_count = 0

    for _, clipboard_path in ipairs(yanked_list) do
      local basename = get_basename(clipboard_path)

      if not file_exists(clipboard_path) then
        ya.err("Path does not exist: " .. clipboard_path)
        error_count = error_count + 1
        goto continue
      end

      local real_path
      if is_symlink(clipboard_path) then
        real_path = resolve_symlink(clipboard_path)
        if not real_path then
          ya.err("Failed to resolve symlink: " .. basename)
          error_count = error_count + 1
          goto continue
        end
        log_debug(basename .. " (symlink) -> " .. real_path)
      else
        if is_cut then
          ya.err("Skipping regular file in cut mode: " .. basename)
          skip_count = skip_count + 1
          goto continue
        end
        real_path = clipboard_path
        log_debug(basename .. " (file) -> " .. real_path)
      end

      local relative_path = get_relative_path(current_dir, real_path)
      if not relative_path then
        ya.err("Failed to calculate relative path: " .. basename)
        error_count = error_count + 1
        goto continue
      end

      log_debug("Relative path: " .. relative_path)

      local new_symlink = current_dir .. "/" .. basename

      if file_exists(new_symlink) then
        ya.err("Symlink already exists: " .. basename)
        error_count = error_count + 1
        goto continue
      end

      local cmd = string.format("ln -s \"%s\" \"%s\"", relative_path, new_symlink)
      local permit = ya.hide()
      local exit_code = os.execute(cmd)
      permit:drop()

      if exit_code == 0 or exit_code == true then
        ya.err("Created symlink: " .. basename .. " -> " .. relative_path)
        success_count = success_count + 1

        -- Delete original symlink if in cut mode
        if is_cut then
          local delete_cmd = string.format("rm \"%s\"", clipboard_path)
          local permit = ya.hide()
          local delete_exit_code = os.execute(delete_cmd)
          permit:drop()

          if delete_exit_code == 0 or delete_exit_code == true then
            ya.err("Deleted original: " .. basename)
          else
            ya.err("Failed to delete original: " .. basename)
          end
        end
      else
        ya.err("Failed to create symlink: " .. basename)
        error_count = error_count + 1
      end

      ::continue::
    end

    if success_count > 0 or error_count > 0 or skip_count > 0 then
      local summary_parts = {}
      if success_count > 0 then table.insert(summary_parts, success_count .. " created") end
      if skip_count > 0 then table.insert(summary_parts, skip_count .. " skipped") end
      if error_count > 0 then table.insert(summary_parts, error_count .. " failed") end
      if #summary_parts > 0 then
        log_debug("Summary: " .. table.concat(summary_parts, ", "))
      end
    end

    -- Refresh Yazi to show new symlinks
    ya.emit("refresh", {})
  end
}
