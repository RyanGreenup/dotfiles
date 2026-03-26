--- Shared treesitter utilities for markdown buffers.
--- All line numbers are 1-indexed to match the Vim API convention.
local M = {}

--- Get the markdown treesitter parser for a buffer.
---@param bufnr number  Buffer number (0 for current)
---@return vim.treesitter.LanguageTree|nil parser  The parser, or nil on failure
function M.get_parser(bufnr)
  bufnr = bufnr or 0
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown')
  if not ok or not parser then
    return nil
  end
  return parser
end

--- Get the root node of the first parse tree.
---@param bufnr number  Buffer number (0 for current)
---@return TSNode|nil root  The root node, or nil on failure
function M.get_root(bufnr)
  local parser = M.get_parser(bufnr)
  if not parser then
    return nil
  end
  local trees = parser:parse()
  if not trees or #trees == 0 then
    return nil
  end
  return trees[1]:root()
end

--- Get the named node at a 1-indexed line.
---@param bufnr number  Buffer number (0 for current)
---@param line number   1-indexed line number
---@return TSNode|nil node  The smallest named node spanning that line
function M.get_node_at_line(bufnr, line)
  local root = M.get_root(bufnr)
  if not root then
    return nil
  end
  local row = line - 1 -- convert to 0-indexed
  return root:named_descendant_for_range(row, 0, row, 0)
end

--- Walk up the tree from the node at `line` to find the enclosing `section` node.
---@param bufnr number  Buffer number (0 for current)
---@param line number   1-indexed line number
---@return TSNode|nil section  The section node, or nil if none found
function M.get_section_at_line(bufnr, line)
  local node = M.get_node_at_line(bufnr, line)
  while node do
    if node:type() == 'section' then
      return node
    end
    node = node:parent()
  end
  return nil
end

--- Find the `atx_heading` node at or above the given line.
--- First checks the node at `line`; if it is not an atx_heading,
--- walks up the tree looking for a section, then returns its heading child.
---@param bufnr number  Buffer number (0 for current)
---@param line number   1-indexed line number
---@return TSNode|nil heading  The atx_heading node, or nil
function M.get_heading_at_line(bufnr, line)
  local node = M.get_node_at_line(bufnr, line)
  if not node then
    return nil
  end
  -- If we landed directly on a heading node, return it
  if node:type() == 'atx_heading' then
    return node
  end
  -- Walk up to the enclosing section and return its heading child
  local section = M.get_section_at_line(bufnr, line)
  if not section then
    return nil
  end
  for child in section:iter_children() do
    if child:named() and child:type() == 'atx_heading' then
      return child
    end
  end
  return nil
end

--- Extract the heading level (1-6) from an atx_heading node.
--- Looks at the `atx_h[1-6]_marker` child to determine the level.
---@param heading_node TSNode  An atx_heading treesitter node
---@return number|nil level  The heading level (1-6), or nil if not determinable
function M.get_heading_level(heading_node)
  if not heading_node or heading_node:type() ~= 'atx_heading' then
    return nil
  end
  for child in heading_node:iter_children() do
    local child_type = child:type()
    local level = child_type:match('^atx_h(%d)_marker$')
    if level then
      return tonumber(level)
    end
  end
  return nil
end

--- Get the 1-indexed line number of the heading in a section.
---@param section TSNode  A section treesitter node
---@return number|nil line  1-indexed line of the heading, or nil
function M.get_heading_line(section)
  if not section then
    return nil
  end
  for child in section:iter_children() do
    if child:named() and child:type() == 'atx_heading' then
      local row = child:start()
      return row + 1
    end
  end
  return nil
end

--- Get direct child section nodes of a section.
---@param section TSNode  A section treesitter node
---@return TSNode[] children  List of child section nodes
function M.get_child_sections(section)
  local children = {}
  if not section then
    return children
  end
  for child in section:iter_children() do
    if child:named() and child:type() == 'section' then
      children[#children + 1] = child
    end
  end
  return children
end

--- Check if a section has any child sections.
---@param section TSNode  A section treesitter node
---@return boolean
function M.has_child_sections(section)
  if not section then
    return false
  end
  for child in section:iter_children() do
    if child:named() and child:type() == 'section' then
      return true
    end
  end
  return false
end

--- Check if a section spans only its heading line (no body content).
---@param section TSNode  A section treesitter node
---@return boolean
function M.is_one_line(section)
  if not section then
    return true
  end
  local start_row = section:start()
  local end_row = section:end_()
  return end_row <= start_row + 1
end

--- Get the 1-indexed start and end lines of a section.
---@param section TSNode  A section treesitter node
---@return number start_line  1-indexed start line
---@return number end_line    1-indexed end line
function M.get_section_range(section)
  local start_row = section:start()
  local end_row = section:end_()
  return start_row + 1, end_row
end

--- Get all headings in a buffer as a structured list.
---@param bufnr number  Buffer number (0 for current)
---@return { node: TSNode, level: number, line: number, text: string }[]
function M.get_all_headings(bufnr)
  local root = M.get_root(bufnr)
  if not root then
    return {}
  end

  local headings = {}

  --- Recursively collect atx_heading nodes from the tree.
  ---@param node TSNode
  local function collect(node)
    for child in node:iter_children() do
      if child:named() then
        if child:type() == 'atx_heading' then
          local level = M.get_heading_level(child)
          local row = child:start()
          local line = row + 1
          local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
          headings[#headings + 1] = {
            node = child,
            level = level or 0,
            line = line,
            text = text,
          }
        elseif child:type() == 'section' then
          collect(child)
        end
      end
    end
  end

  collect(root)
  return headings
end

return M
