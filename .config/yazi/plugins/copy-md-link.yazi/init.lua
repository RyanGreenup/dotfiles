--[[
# Yazi Plugin Template
## Introduction
This is a template for a Yazi plugin. It is a simple plugin that copies a markdown link to the clipboard
## Debugging and Logs
debug with ya.err("foo") and tail -f ~/.local/state/yazi/yazi.log
## See Also

* [Tips | Yazi](https://yazi-rs.github.io/docs/tips/#selected-files-to-clipboard)
* [Plugins (BETA) | Yazi](https://yazi-rs.github.io/docs/plugins/overview/#logging)
* [Plugin creation: How do you loop over all selected files · sxyazi/yazi · Discussion #1117](https://github.com/sxyazi/yazi/discussions/1117)
--]]

-- Get the path separator for windows or unix
local path_sep = package.config:sub(1, 1)


--[[
Get's the hovered path, adapted from yamb plugin:
    * /home/ryan/.config/yazi/plugins/yamb.yazi/init.lua
--]]
local get_hovered_path = ya.sync(function(state)
  local h = cx.active.current.hovered
  if h then
    local path = tostring(h.url)
    if h.cha.is_dir then
      return path .. path_sep
    end
    return path
  else
    return ''
  end
end)

local function Basename(path)
  return string.gmatch(path, "[^/]*$")()
end

return {
  entry = function(self, args)
    local file = get_hovered_path()

    -- test if the file ends in .md
    local link = file
    local ext_regex = "%.md$"
    if string.match(file, ext_regex) then
      local title = ""

      -- Strip Extension

      -- Get the basename of the file
      title = Basename(file)

      -- Replace underscores with spaces
      title = string.gsub(title, ext_regex, "")
      title = string.gsub(title, "_", " / ")
      title = string.gsub(title, "-", " ")

      -- Make a link
      link = "[" .. title .. "](" .. file .. ")"
    end

    -- Protect the link for the shell
    link = "'" .. link .. "'"
    -- Copy to clipboard
    os.execute("echo " .. link .. " | wl-copy")

    ya.err("Copied " .. link .. " to clipboard")
  end
}
