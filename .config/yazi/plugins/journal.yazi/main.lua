-- Journal Plugin for Yazi
-- Navigates to $HOME/Sync/journals/yyyy/mm/dd, creating the directory if needed

local function get_journal_path()
  local home = os.getenv("HOME")
  local date = os.date("%Y/%m/%d")
  return home .. "/Sync/journals/" .. date
end

local function ensure_dir_exists(path)
  os.execute("mkdir -p \"" .. path .. "\"")
end

return {
  entry = function(self, args)
    local path = get_journal_path()
    ensure_dir_exists(path)

    -- Emit cd command to navigate to the journal directory
    ya.manager_emit("cd", { path })

    ya.err("Navigated to journal: " .. path)
  end
}
