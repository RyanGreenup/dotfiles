local M = {} -- define a table to hold our module

local fterm = require("FTerm")

local sidebar_dims = {
  height = 0.9,
  width = 0.5,
  x = 0.9,
  y = 0,
}

local function sidebar_popup(cmd)
  return fterm:new({
    cmd = cmd,
    dimensions = sidebar_dims
  })
end

M.tmux = fterm:new({ cmd = "tmux" })
M.gitui = sidebar_popup("tmux a")
M.note_search = sidebar_popup([[ai-tools --ollama-host "http://vale:11434" live-search --no-fzf]])




-- Return the module table so that it can be required by other scripts
return M
