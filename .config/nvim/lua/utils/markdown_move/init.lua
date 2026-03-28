local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local M = {}

local script_path = vim.fn.stdpath("config") .. "/scripts/bun-markdown-link/index.ts"

--- Canonical set of markdown-like file extensions (lowercase, without dot).
M.markdown_extensions = {
  md = true,
  mdx = true,
  mdoc = true,
  rmd = true,
  qmd = true,
  Rmd = true,
  mdown = true,
  mkd = true,
  mkdn = true,
  markdown = true,
}

--- Canonical set of markdown-like vim filetypes (lowercase).
M.markdown_filetypes = {
  markdown = true,
  mdx = true,
  mdoc = true,
  rmd = true,
  rmarkdown = true,
  pandoc = true,
  quarto = true,
  vimwiki = true,
}

--- Check if a filename has a markdown-like extension.
---@param filename string
---@return boolean
function M.is_markdown_ext(filename)
  local ext = vim.fn.fnamemodify(filename, ":e"):lower()
  return M.markdown_extensions[ext] or false
end

--- Check if the current buffer's filetype is markdown-like.
---@return boolean
function M.is_markdown_filetype()
  local ft = vim.bo.filetype:lower()
  return M.markdown_filetypes[ft] or false
end

--- Build a glob string for find_files to filter markdown extensions.
---@return string[]
local function markdown_globs()
  local globs = {}
  for ext in pairs(M.markdown_extensions) do
    table.insert(globs, "*." .. ext)
  end
  return globs
end

--- Move the current file to a target directory using the bun script,
--- which also updates all internal and external markdown links.
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

  local cmd = { "bun", "run", script_path, "move", src, target_dir }
  vim.notify("Moving file...", vim.log.levels.INFO)

  vim.system(cmd, { text = true, timeout = 10000 }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          string.format("Move failed (exit %s): %s", tostring(result.code), result.stderr or ""),
          vim.log.levels.ERROR
        )
        return
      end
      vim.cmd("edit " .. vim.fn.fnameescape(dest))
      vim.notify("Moved to " .. dest)
    end)
  end)
end

--- Generate a markdown link to a target file using the bun script.
---@param target string Absolute path to the target file
---@param callback fun(link: string) Called with the generated markdown link text
function M.generate_link(target, callback)
  local cmd = { "bun", "run", script_path, "link", target }
  vim.system(cmd, { text = true, timeout = 5000 }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          string.format("Link generation failed (exit %s): %s", tostring(result.code), result.stderr or ""),
          vim.log.levels.ERROR
        )
        return
      end
      local link = vim.trim(result.stdout or "")
      if link ~= "" then
        callback(link)
      end
    end)
  end)
end

---@class PickAndInsertLinkOpts
---@field markdown_only? boolean Only show markdown files (default: true)

--- Insert a markdown link at cursor by picking a file from cwd via Telescope.
---@param opts? PickAndInsertLinkOpts
function M.pick_and_insert_link(opts)
  if not M.is_markdown_filetype() then
    vim.notify("Not a markdown-like filetype (current: " .. vim.bo.filetype .. ")", vim.log.levels.WARN)
    return
  end

  opts = opts or {}
  local markdown_only = opts.markdown_only ~= false

  local cwd = vim.fn.getcwd()
  local find_opts = {
    prompt_title = "Insert markdown link",
    cwd = cwd,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if not selection then return end
        local target = cwd .. "/" .. selection[1]
        M.generate_link(target, function(link)
          vim.api.nvim_put({ link }, "", false, true)
        end)
      end)
      return true
    end,
  }

  if markdown_only then
    find_opts.find_command = { "rg", "--files", "--glob" }
    -- rg --files only takes one --glob, so build with multiple --glob flags
    local cmd = { "rg", "--files" }
    for _, glob in ipairs(markdown_globs()) do
      table.insert(cmd, "--glob")
      table.insert(cmd, glob)
    end
    find_opts.find_command = cmd
  end

  require("telescope.builtin").find_files(find_opts)
end

---@param root string
---@return string[]
local function list_dirs_recursive(root)
  local dirs = {}
  local function scan(dir)
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return end
    while true do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then break end
      if typ == "directory" and name:sub(1, 1) ~= "." then
        local full = dir .. "/" .. name
        table.insert(dirs, full)
        scan(full)
      end
    end
  end
  scan(root)
  table.sort(dirs)
  return dirs
end

---@param dir string
---@return string
local function dir_contents_preview(dir)
  local lines = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return "(empty or unreadable)" end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end
    local prefix = typ == "directory" and "d " or "  "
    table.insert(lines, prefix .. name)
  end
  table.sort(lines)
  if #lines == 0 then return "(empty directory)" end
  return table.concat(lines, "\n")
end

--- Open a Telescope picker to choose a directory, then move the current file there.
function M.pick_and_move()
  if not M.is_markdown_filetype() then
    vim.notify("Not a markdown-like filetype (current: " .. vim.bo.filetype .. ")", vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.getcwd()
  local dirs = list_dirs_recursive(cwd)
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
