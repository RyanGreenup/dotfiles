local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local M = {}

local markdown_filetypes = {
  markdown = true,
  mdx = true,
  mdoc = true,
  rmd = true,
  rmarkdown = true,
  pandoc = true,
  quarto = true,
  vimwiki = true,
}

--- Check if the current buffer's filetype is markdown-like.
---@return boolean
local function is_markdown_like()
  local ft = vim.bo.filetype:lower()
  return markdown_filetypes[ft] or false
end

--- Move the current file to a target directory.
--- TODO: Handle renaming at a later date with a TypeScript module.
---@param target_dir string Absolute path to the destination directory
function M.move_file(target_dir)
  local src = vim.api.nvim_buf_get_name(0)
  if src == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.fnamemodify(src, ":t")
  local dest = target_dir .. "/" .. filename

  if vim.fn.filereadable(dest) == 1 then
    vim.notify("File already exists at " .. dest, vim.log.levels.ERROR)
    return
  end

  local ok, err = os.rename(src, dest)
  if not ok then
    vim.notify("Move failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(dest))
  vim.notify("Moved to " .. dest)
end

--- List subdirectories of a given path (non-recursive).
---@param path string
---@return string[]
local function list_dirs(path)
  local dirs = {}
  local handle = vim.loop.fs_scandir(path)
  if not handle then return dirs end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if typ == "directory" and name:sub(1, 1) ~= "." then
      table.insert(dirs, path .. "/" .. name)
    end
  end
  table.sort(dirs)
  return dirs
end

--- List files in a directory for preview display.
---@param dir string
---@return string
local function dir_contents_preview(dir)
  local lines = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return "(empty or unreadable)" end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end
    local prefix = typ == "directory" and "📁 " or "  "
    table.insert(lines, prefix .. name)
  end
  table.sort(lines)
  if #lines == 0 then return "(empty directory)" end
  return table.concat(lines, "\n")
end

--- Open a Telescope picker to choose a directory, then move the current file there.
function M.pick_and_move()
  if not is_markdown_like() then
    vim.notify("Not a markdown-like filetype (current: " .. vim.bo.filetype .. ")", vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.getcwd()
  local dirs = list_dirs(cwd)
  -- Include cwd itself as an option (move to current dir root)
  table.insert(dirs, 1, cwd)

  pickers.new({ theme = "ivy" }, {
    prompt_title = "Move file to directory",
    finder = finders.new_table({
      results = dirs,
      entry_maker = function(entry)
        local display = vim.fn.fnamemodify(entry, ":.")
        if entry == cwd then display = ". (current dir)" end
        return {
          value = entry,
          display = display,
          ordinal = display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "Directory Contents",
      define_preview = function(self, entry)
        local contents = dir_contents_preview(entry.value)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(contents, "\n"))
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.move_file(selection.value)
        end
      end)
      return true
    end,
  }):find()
end

return M
