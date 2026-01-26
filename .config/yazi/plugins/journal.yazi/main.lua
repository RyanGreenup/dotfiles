-- Journal Plugin for Yazi
-- Navigates to $HOME/Sync/journals/yyyy/mm/dd, creating the directory if needed

return {
  entry = function(self, args)
    local home = os.getenv("HOME")
    local date = os.date("%Y/%m/%d")
    local path = home .. "/Sync/journals/" .. date

    -- Create directory if needed (synchronous, like yamb plugin uses io.open)
    os.execute('mkdir -p "' .. path .. '"')

    ya.emit("cd", { path })
  end
}
