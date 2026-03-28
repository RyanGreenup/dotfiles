local M = {}

---Get the section node containing the given line.
---Walks up the tree from the node at `line` until it finds a `section` node.
---@param bufnr number
---@param line number 1-indexed line number
---@return TSNode|nil
function M.get_section_at_line(bufnr, line)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown')
  if not ok or not parser then
    return nil
  end
  local trees = parser:parse()
  if not trees or #trees == 0 then
    return nil
  end
  local root = trees[1]:root()
  local node = root:named_descendant_for_range(line - 1, 0, line - 1, 0)
  while node do
    if node:type() == 'section' then
      return node
    end
    node = node:parent()
  end
  return nil
end

---Get direct child section nodes of a section.
---@param section TSNode
---@return TSNode[]
function M.get_child_sections(section)
  local children = {}
  for child in section:iter_children() do
    if child:named() and child:type() == 'section' then
      children[#children + 1] = child
    end
  end
  return children
end

---Check if a section has any child sections.
---@param section TSNode
---@return boolean
function M.has_child_sections(section)
  for child in section:iter_children() do
    if child:named() and child:type() == 'section' then
      return true
    end
  end
  return false
end

---Get the 1-indexed line number of the heading in a section.
---@param section TSNode
---@return number|nil
function M.get_heading_line(section)
  for child in section:iter_children() do
    if child:named() and child:type() == 'atx_heading' then
      local row = child:start()
      return row + 1
    end
  end
  return nil
end

---Check if a section spans only its heading line (no body content).
---@param section TSNode
---@return boolean
function M.is_one_line(section)
  local start_row = section:start()
  local end_row = section:end_()
  return end_row <= start_row + 1
end

return M
