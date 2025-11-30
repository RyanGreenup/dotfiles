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
  log_debug("Reading yanked files from cx.yanked")

  for idx, url in pairs(cx.yanked) do
    local path = tostring(url)
    log_debug("Yanked file " .. idx .. ": " .. path)
    table.insert(yanked_list, path)
  end

  log_debug("Total yanked files: " .. #yanked_list)

  local cwd = tostring(cx.active.current.cwd)
  log_debug("Current working directory: " .. cwd)

  local is_cut = cx.yanked.is_cut
  local mode = is_cut and "CUT" or "YANK"
  log_debug("Mode: " .. mode)

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
      log_debug("Processing: " .. clipboard_path)

      if not file_exists(clipboard_path) then
        log_debug("ERROR: Path does not exist: " .. clipboard_path)
        ya.err("Path does not exist: " .. clipboard_path)
        error_count = error_count + 1
        goto continue
      end

      log_debug("File/symlink exists: " .. clipboard_path)

      local real_path
      if is_symlink(clipboard_path) then
        log_debug("Detected symlink, resolving...")
        real_path = resolve_symlink(clipboard_path)
        if not real_path then
          log_debug("ERROR: Failed to resolve symlink: " .. clipboard_path)
          ya.err("Failed to resolve symlink: " .. clipboard_path)
          error_count = error_count + 1
          goto continue
        end
        log_debug("Resolved symlink to: " .. real_path)
      else
        log_debug("Detected regular file")
        if is_cut then
          local basename = get_basename(clipboard_path)
          log_debug("SKIP: In cut mode with regular file: " .. basename)
          ya.err("Skipping regular file in cut mode: " .. basename)
          skip_count = skip_count + 1
          goto continue
        end
        log_debug("In yank mode, using regular file directly")
        real_path = clipboard_path
        log_debug("Using target path: " .. real_path)
      end

      local basename = get_basename(clipboard_path)
      log_debug("Symlink basename: " .. basename)

      local relative_path = get_relative_path(current_dir, real_path)
      if not relative_path then
        log_debug("ERROR: Failed to calculate relative path from " .. current_dir .. " to " .. real_path)
        ya.err("Failed to calculate relative path")
        error_count = error_count + 1
        goto continue
      end

      log_debug("Calculated relative path: " .. relative_path)

      local new_symlink = current_dir .. "/" .. basename
      log_debug("Target symlink location: " .. new_symlink)

      if file_exists(new_symlink) then
        log_debug("ERROR: Symlink already exists: " .. new_symlink)
        ya.err("Symlink already exists: " .. new_symlink)
        error_count = error_count + 1
        goto continue
      end

      local cmd = string.format("ln -s \"%s\" \"%s\"", relative_path, new_symlink)
      log_debug("Executing command: " .. cmd)

      local permit = ya.hide()
      local exit_code = os.execute(cmd)
      permit:drop()

      if exit_code == 0 or exit_code == true then
        log_debug("SUCCESS: Created symlink " .. basename .. " -> " .. relative_path)
        ya.err("Created symlink: " .. basename .. " -> " .. relative_path)
        success_count = success_count + 1

        -- Delete original symlink if in cut mode
        if is_cut then
          log_debug("In cut mode, deleting original symlink: " .. clipboard_path)
          local delete_cmd = string.format("rm \"%s\"", clipboard_path)
          log_debug("Executing delete command: " .. delete_cmd)
          local permit = ya.hide()
          local delete_exit_code = os.execute(delete_cmd)
          permit:drop()

          if delete_exit_code == 0 or delete_exit_code == true then
            log_debug("SUCCESS: Deleted original symlink: " .. basename)
            ya.err("Deleted original symlink: " .. basename)
          else
            log_debug("ERROR: Failed to delete original symlink (exit code: " .. tostring(delete_exit_code) .. ")")
            ya.err("Failed to delete original symlink: " .. basename)
          end
        end
      else
        log_debug("ERROR: Failed to create symlink (exit code: " .. exit_code .. ")")
        ya.err("Failed to create symlink: " .. basename)
        error_count = error_count + 1
      end

      ::continue::
    end

    log_debug("=== Symlink paste operation complete ===")
    log_debug("Summary: " .. success_count .. " succeeded, " .. error_count .. " failed, " .. skip_count .. " skipped")

    -- Refresh Yazi to show new symlinks
    ya.manager_emit("refresh", {})
  end
}
