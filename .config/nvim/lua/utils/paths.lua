--[[
  path_to_pattern(base_path)
  Returns a string that can be used as a pattern by escaping
  dashes and dots with percentage

  Example
  path_to_pattern("/tmp/2024-03-02.journal.notes.lua")
  Returns "/tmp/2024%-03%-02%.journal%.notes%.lua"
--]]
function Path_to_pattern(path)
  local base_path = Basename(path)
  local base_path_pattern = string.gsub(base_path, "%-", [[%%-]])
  local base_path_pattern = string.gsub(base_path_pattern, "%.", [[%%.]])
  return base_path_pattern
end

function Basename(path)
  return string.gmatch(path, "[^/]*$")()
end

--[[
  Dirname
  returns the directory name of a path
--]]
function Dirname(path)
    return string.gsub(path, Path_to_pattern(path), "")
end


--[[
  Strip_extension
  strips the extension from a string

  Parameters:
  S - string to strip the extension from
  Returns:
  S - string without the extension

  Implementation:
  Creates an empty new string.
  Reverses the original string and loops over each character. Characters
  that are after the first dot are included in the new string.
--]]
function Strip_extension(s)
-- loop over s
local before_dot = true
  local new_s = ""
  s = string.reverse(s)
  for i = 1, #s do
      local c = s:sub(i, i)
      if not before_dot then
        new_s = new_s .. c
      elseif c == "." then
        before_dot = false
      else
      end
  end
  new_s = string.reverse(new_s)
  return new_s
end
