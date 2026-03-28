local ts = require('md_fold.treesitter')

local M = {}

---Echo a message at INFO level.
---@param msg string
local function echo_info(msg)
  vim.api.nvim_echo({ { msg, 'MoreMsg' } }, false, {})
end

---Local fold cycle on the current line. Mirrors orgmode's OrgMappings:cycle().
---Three-state cycle: Folded → Children visible → Fully expanded → Folded
function M.cycle()
  local line = vim.fn.line('.')

  if not vim.wo.foldenable then
    vim.wo.foldenable = true
    vim.cmd('silent! norm! zx')
  end

  local level = vim.fn.foldlevel(line)
  if level == 0 then
    return echo_info('No fold')
  end

  if vim.fn.foldclosed(line) ~= -1 then
    return vim.cmd('silent! norm! zo')
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    return
  end

  local is_expandable = function(sec)
    return ts.has_child_sections(sec) or not ts.is_one_line(sec)
  end

  if not is_expandable(section) then
    return
  end

  local children = ts.get_child_sections(section)
  local close = #children == 0

  if not close then
    local has_nested_children = false
    for _, child in ipairs(children) do
      local child_expandable = is_expandable(child)
      if not has_nested_children and child_expandable then
        has_nested_children = true
      end
      local child_line = ts.get_heading_line(child)
      if child_line and child_expandable and vim.fn.foldclosed(child_line) == -1 then
        vim.cmd(string.format('silent! keepjumps norm! %dggzc', child_line))
        close = true
      end
    end
    vim.cmd(string.format('silent! keepjumps norm! %dgg', line))
    if not close and not has_nested_children then
      close = true
    end
  end

  if close then
    return vim.cmd('silent! norm! zc')
  end
  return vim.cmd('silent! norm! zczO')
end

---Global fold cycle for the whole buffer. Mirrors orgmode's OrgMappings:global_cycle().
---Cycles: Overview → Contents → Show All → Overview
function M.global_cycle()
  if not vim.wo.foldenable or vim.w.md_fold_global_state == 'Show All' then
    vim.w.md_fold_global_state = 'Overview'
    echo_info('Overview')
    return vim.cmd('silent! norm! zMzX')
  end
  if vim.w.md_fold_global_state == 'Contents' then
    vim.w.md_fold_global_state = 'Show All'
    echo_info('Show All')
    return vim.cmd('silent! norm! zR')
  end
  vim.w.md_fold_global_state = 'Contents'
  echo_info('Contents')
  vim.wo.foldlevel = 1
  return vim.cmd('silent! norm! zx')
end

return M
