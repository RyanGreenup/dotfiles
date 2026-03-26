--- Custom foldtext formatting for orgmark.
--- Produces a clean one-line summary for folded sections.
local config = require('orgmark.config')

local M = {}

--- Conceal markdown links [text](url) -> text when conceallevel > 0.
---@param text string  The raw line text
---@return string text  The text with links concealed (if applicable)
local function conceal_links(text)
  if vim.wo.conceallevel > 0 then
    text = text:gsub('%[([^%]]+)%]%([^%)]+%)', '%1')
  end
  return text
end

--- Custom foldtext function for markdown files.
--- Called by Neovim via `v:lua.require('orgmark.folding.text').foldtext()`.
---@return string  The formatted fold text
function M.foldtext()
  local cfg = config.current.folding
  local start_line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart

  local text = conceal_links(start_line)
  text = text .. ' ' .. cfg.ellipsis

  if cfg.show_line_count then
    text = text .. ' (' .. line_count .. ' lines)'
  end

  return text
end

return M
