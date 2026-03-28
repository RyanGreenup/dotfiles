local M = {}

---Conceal markdown links [text](url) → text when conceallevel > 0.
---@param text string
---@return string
local function conceal_links(text)
  if vim.wo.conceallevel > 0 then
    text = text:gsub('%[([^%]]+)%]%([^%)]+%)', '%1')
  end
  return text
end

---Custom foldtext function for markdown files.
---@return string
function M.foldtext()
  local start_line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart
  local text = conceal_links(start_line)
  return text .. ' ... (' .. line_count .. ' lines)'
end

return M
