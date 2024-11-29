local M = {} -- define a table to hold our module

local themes = { "catppuccin-macchiato", "catppuccin-latte" }

--- Check if gsettings reports
local function is_system_light_mode(opts)
  if opts ~= nil then
    if opts.system == "linux" then
      local is_light_mode = false
      local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme", "r")
      if handle == nil then
        return false
      else
        local result = handle:read("*a")
        handle:close()
        if result:match("prefer-light") then
          return true
        else
          return false
        end
      end
    end
  else
    print("Not implemented for systems other than linux")
    return false
  end
end


function M.setup(opts)
  if opts == nil then
    vim.cmd.colorscheme(themes[1])
  elseif opts.auto then
    print("Auto detection of light mode enabled not yet implemented")
    if is_system_light_mode({ system = "linux" }) then
      vim.cmd.colorscheme(themes[2])
    else
      vim.cmd.colorscheme(themes[1])
    end
  end
end

-- Define the function we want to export
function M.toggle()
  if vim.g.colors_name == themes[2] then
    vim.cmd.colorscheme(themes[1])
  else
    vim.cmd.colorscheme(themes[2])
  end
end

-- Return the module table so that it can be required by other scripts
return M
