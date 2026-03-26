--- Heading navigation: next/prev heading, sibling, and parent.
--- Uses `get_all_headings()` from treesitter.lua and centers the view after jumping.
local M = {}

local ts = require('orgmark.treesitter')

--- Jump to a 1-indexed line and center the view.
---@param line number  1-indexed target line
local function jump_and_center(line)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd('normal! zz')
end

--- Jump to the next heading of any level.
--- Searches forward from the current line.
function M.next_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  local all = ts.get_all_headings(bufnr)
  for _, h in ipairs(all) do
    if h.line > current_line then
      jump_and_center(h.line)
      return
    end
  end

  vim.notify('No next heading found', vim.log.levels.INFO)
end

--- Jump to the previous heading of any level.
--- Searches backward from the current line.
function M.prev_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  local all = ts.get_all_headings(bufnr)
  for i = #all, 1, -1 do
    if all[i].line < current_line then
      jump_and_center(all[i].line)
      return
    end
  end

  vim.notify('No previous heading found', vim.log.levels.INFO)
end

--- Jump to the next sibling heading (same level, same parent section).
--- Finds the current heading's level and parent section, then searches
--- forward for the next heading at the same level under the same parent.
function M.next_sibling()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  local section = ts.get_section_at_line(bufnr, current_line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local heading = ts.get_heading_at_line(bufnr, current_line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local level = ts.get_heading_level(heading)
  if not level then
    return
  end

  -- Find the parent of the current section to get sibling sections
  local parent = section:parent()
  if not parent then
    vim.notify('No parent section found', vim.log.levels.INFO)
    return
  end

  -- Iterate through children of the parent to find the next sibling section
  local found_current = false
  for child in parent:iter_children() do
    if child:named() and child:type() == 'section' then
      if found_current then
        -- Check if this sibling has a heading at the same level
        local sibling_heading_line = ts.get_heading_line(child)
        if sibling_heading_line then
          local sibling_heading = ts.get_heading_at_line(bufnr, sibling_heading_line)
          if sibling_heading then
            local sibling_level = ts.get_heading_level(sibling_heading)
            if sibling_level == level then
              jump_and_center(sibling_heading_line)
              return
            end
          end
        end
      elseif child:id() == section:id() then
        found_current = true
      end
    end
  end

  vim.notify('No next sibling heading found', vim.log.levels.INFO)
end

--- Jump to the previous sibling heading (same level, same parent section).
--- Searches backward for the previous heading at the same level under the same parent.
function M.prev_sibling()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  local section = ts.get_section_at_line(bufnr, current_line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local heading = ts.get_heading_at_line(bufnr, current_line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local level = ts.get_heading_level(heading)
  if not level then
    return
  end

  local parent = section:parent()
  if not parent then
    vim.notify('No parent section found', vim.log.levels.INFO)
    return
  end

  -- Collect all sibling sections, then find the one before current
  local siblings = {}
  local current_idx = nil
  for child in parent:iter_children() do
    if child:named() and child:type() == 'section' then
      siblings[#siblings + 1] = child
      if child:id() == section:id() then
        current_idx = #siblings
      end
    end
  end

  if not current_idx or current_idx <= 1 then
    vim.notify('No previous sibling heading found', vim.log.levels.INFO)
    return
  end

  -- Search backward through preceding siblings for one at the same level
  for i = current_idx - 1, 1, -1 do
    local sibling = siblings[i]
    local sibling_heading_line = ts.get_heading_line(sibling)
    if sibling_heading_line then
      local sibling_heading = ts.get_heading_at_line(bufnr, sibling_heading_line)
      if sibling_heading then
        local sibling_level = ts.get_heading_level(sibling_heading)
        if sibling_level == level then
          jump_and_center(sibling_heading_line)
          return
        end
      end
    end
  end

  vim.notify('No previous sibling heading found', vim.log.levels.INFO)
end

--- Jump to the parent heading.
--- Finds the section containing the current section and jumps to its heading.
function M.parent_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  local section = ts.get_section_at_line(bufnr, current_line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  -- Walk up to find the parent section (skip non-section parents like document root)
  local parent = section:parent()
  while parent do
    if parent:type() == 'section' then
      local parent_heading_line = ts.get_heading_line(parent)
      if parent_heading_line then
        jump_and_center(parent_heading_line)
        return
      end
    end
    parent = parent:parent()
  end

  vim.notify('No parent heading found', vim.log.levels.INFO)
end

return M
