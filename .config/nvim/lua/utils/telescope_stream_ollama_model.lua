-- See the docs for telescope at <https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md>
-- nmap <F1> :luafile %<CR>

local M = {} -- define a table to hold our module


local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

---Boilerplate telescope function to insert the selected item
---Default is to go to that buffer
---@param prompt_bufnr number
---@param map table
local function telescope_attach_set_binding(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    print(vim.inspect(selection))
    local model = selection[1]
    local cmd = string.format(
      [[vmap <Insert> <cmd>lua require('utils/stream_ollama').stream_selection_to_ollama('%s', 'vale')<CR>]], model)
    vim.cmd(cmd)
  end)
  return true
end

local pick_notes = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Notes",
    sorter = conf.generic_sorter(opts),
    attach_mappings = telescope_attach_set_binding,
    finder = finders.new_table {
      results = { "codestral:latest", "phi3", "command-r", "mathstral" }
    },
  }):find()
end

-- Define the function we want to export
function M.choose_model()
  pick_notes()
end

return M
