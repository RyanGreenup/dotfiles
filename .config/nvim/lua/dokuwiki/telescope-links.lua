-- See the docs for telescope at <https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md>
-- nmap <F1> :luafile %<CR>

local M = {} -- define a table to hold our module


local function shell(cmd)
  local handle = io.popen(cmd)
  if handle == nil then
    print("Failed to run the command.")
  else
    local output = handle:read("*a")
    handle:close()
    return output
  end
end


--------------------------------------------------------------------------------
-- Get Notes -------------------------------------------------------------------
--------------------------------------------------------------------------------

---Creates a title from a file path
---@param path string
---@return string
local function make_title(path)
  -- local title ---@type string: The title to return
  -- local base_no_ext ---@type string: Base name without extension
  -- -- basename
  -- base_no_ext = vim.fn.fnamemodify(path, ":t:r")
  -- -- Change extensions etc.
  -- title = base_no_ext:gsub("-", " "):gsub("_", " / ")
  -- -- title case
  -- title = title:gsub("(%a)([%w_']*)", function(first, rest)
  --   return first:upper() .. rest:lower()
  -- end)
  -- return title
  -- return '[[' .. path .. ']]'
  return path
end

---Creates a markdown link from a file path
---@param path string: the target path to the file
---@return string: A markdown link with a formatted title
local function make_link(path)
  return '[[' .. path .. ']]'
end


---@param path string
---@return string
local function expanduser(path)
  local home = os.getenv("HOME")
  if home == nil then
    -- use plenary if needed
    home = require("plenary.path").new({ "~" }):expand()
  end
  local fixed_path, _ = path:gsub("^~", home)
  return fixed_path
end



--- Drop leading dir and reject non-md
---@param files table: (table[string]) list of files
---@return table: (table[string])list of '.md' files with leading dir removed
local function clean_links(files, current_dir)
  if current_dir == nil then
    current_dir = vim.fn.getcwd()
  end
  local new_files = {}
  for _, file in ipairs(files) do
    -- This requires us to be in that directory see [note_cd_here]
    -- Gives relative path
    file = file:gsub(current_dir .. "/", "")
    local ext = vim.fn.fnamemodify(file, ":e")
    if ext == "txt" then
      table.insert(new_files, file)
    end
  end
  return new_files
end



local function get_note_paths(dir, filter_for_markdown)
  if filter_for_markdown == nil then
    filter_for_markdown = true
  end
  local dir_path = expanduser(dir)
  local files = vim.fn.globpath(dir_path, "**", true, true) ---@type table
  if filter_for_markdown then
    files = clean_links(files, dir_path)
  end
  return files
end

---Takes a list of files and creates a markdown link for each
---@param files table: (table[string]) list of files
---@return table: (table[string, string]) list of files and corresponding markdown link
function create_files_and_link_pairs(files)
  local files_and_links = {}
  for _, file in ipairs(files) do
    table.insert(files_and_links, { file, make_link(file) })
  end
  return files_and_links
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

---Replace a directory with a relative path using python if needed
---@param path string
---@return string
local function get_relpath(dir, path)
  local path = path:gsub(dir, "")
  path = path:gsub("/", ":")
  path = path:gsub([[\]], ":")
  path = path:gsub([[.txt]], "")
  return path
end

---Boilerplate telescope function to insert the selected item
---Default is to go to that buffer
---@param prompt_bufnr number
---@param map table
local function telescope_attach_insert_text(prompt_bufnr, map, dir)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    print(vim.inspect(selection))
    -- todo use dir here
    local file = get_relpath(dir, selection[1])
    local link = make_link(file)
    vim.api.nvim_put({ link }, "", false, true)
  end)
  return true
end


---Boilerplate telescope function to insert the selected item
---Default is to go to that buffer
---@param prompt_bufnr number
---@param map table
local function telescope_attach_copy_file(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    print(vim.inspect(selection))
    local file = selection[1]
    -- TODO check if the file would clobber another
    local basename = vim.fn.fnamemodify(file, ":t")
    -- copy the file into ./assets
    shell("cp " .. file .. " ./assets/")
    local link = string.format("![%s](./assets/%s)", basename, basename)
    vim.api.nvim_put({ link }, "", false, true)
  end)
  return true
end

local pick_notes = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Notes",
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      telescope_attach_insert_text(prompt_bufnr, map, opts['my_keys_notes_dir'])
      return true
    end,
    previewer = conf.file_previewer(opts),
    finder = finders.new_table {
      results = get_note_paths(opts['my_keys_notes_dir']),
    },
  }):find()
end


local function ripgrep(search_string)
  local out = shell("rg -l " .. search_string)
  -- Split into a table
  out = vim.split(out, "\n")
  -- Remove empty lines
  out = vim.tbl_filter(function(line)
    return line ~= ""
  end, out)
  return out
end

local function rg_backlinks(file)
  return ripgrep(file)
end

local function get_backlinks()
  return ripgrep(vim.fn.expand("%:t"))
end

local open_backlink = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Notes",
    sorter = conf.generic_sorter(opts),
    previewer = conf.file_previewer(opts),
    finder = finders.new_table {
      results = get_backlinks()
    },
  }):find()
end

local function fd_files(opts)
  local files = shell("fd -t f . ~")

  -- Split into a table
  local lines = vim.split(out, "\n")
  -- Remove empty lines
  lines = vim.tbl_filter(function(line)
    return line ~= ""
  end, lines)

  return lines
end


local grab_attachment = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Files",
    sorter = conf.generic_sorter(opts),
    attach_mappings = telescope_attach_copy_file,
    previewer = conf.file_previewer(opts),
    finder = finders.new_table {
      results = get_note_paths("~")
    },
  }):find()
end



-- Define the function we want to export
function M.insert_notes_link(opts)
  opts = opts or {
    my_keys_notes_dir = "~/Applications/Docker/dokuwiki/data/pages"
  }
  -- Change directory see [note_cd_here]
  local current_dir = vim.fn.getcwd()
  vim.fn.chdir(opts['my_keys_notes_dir'])
  pick_notes(opts)
  -- Runs async, no need to change back in this case
  -- vim.fn.chdir(current_dir)
end

function M.open_backlink()
  open_backlink()
end

function M.todo()
  grab_attachment()
end

return M
