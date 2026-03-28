local M = {}

local script_path = vim.fn.stdpath("config") .. "/scripts/bun-citations/index.ts"

--- Find a CSL-JSON references file in the given directory
---@param dir string
---@return string|nil
local function find_references_json(dir)
  local entries = vim.fn.glob(dir .. "/*.json", false, true)
  if #entries == 0 then
    return nil
  end
  for _, entry in ipairs(entries) do
    if vim.fn.fnamemodify(entry, ":t") == "references.json" then
      return entry
    end
  end
  return entries[1]
end

--- Parse a CSL-JSON file, returning list of items
---@param path string
---@return table|nil items
---@return string|nil error
local function parse_csl_json(path)
  local f = io.open(path, "r")
  if not f then
    return nil, "Cannot open file: " .. path
  end
  local content = f:read("*a")
  f:close()
  local ok, result = pcall(vim.json.decode, content)
  if not ok then
    return nil, "JSON parse error in " .. path .. ": " .. tostring(result)
  end
  if type(result) ~= "table" then
    return nil, "Expected JSON array in " .. path
  end
  return result, nil
end

--- Format a CSL-JSON item for display
---@param item table
---@return string
local function csl_to_display(item)
  local key = item.id or "unknown"
  local title = item.title or "Untitled"
  local author = "Unknown"
  if item.author and item.author[1] then
    author = item.author[1].family or item.author[1].literal or "Unknown"
  end
  local year = ""
  if item.issued and item.issued["date-parts"] and item.issued["date-parts"][1] then
    year = tostring(item.issued["date-parts"][1][1] or "")
  end
  return string.format("[@%s] — %s (%s, %s)", key, title, author, year)
end

--- Open Telescope picker for existing citations
function M.pick_citation()
  local cwd = vim.fn.getcwd()
  local json_path = find_references_json(cwd)
  if not json_path then
    vim.notify("No CSL-JSON references file found in " .. cwd, vim.log.levels.WARN)
    return
  end

  local items, err = parse_csl_json(json_path)
  if not items then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  if #items == 0 then
    vim.notify("No citations found in " .. json_path, vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local results = {}
  for _, item in ipairs(items) do
    table.insert(results, { display = csl_to_display(item), key = item.id })
  end

  pickers
    .new({}, {
      prompt_title = "Citations",
      sorter = conf.generic_sorter({}),
      finder = finders.new_table({
        results = results,
        entry_maker = function(entry)
          return {
            value = entry.key,
            display = entry.display,
            ordinal = entry.display,
          }
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.api.nvim_put({ "[@" .. selection.value .. "]" }, "", false, true)
          end
        end)
        return true
      end,
    })
    :find()
end

--- Run the bun citation fetcher and handle results
---@param url string
local function fetch_citation(url)
  local cwd = vim.fn.getcwd()
  local cmd = { "bun", "run", script_path, url, "--dir=" .. cwd }
  vim.notify("Fetching citation...", vim.log.levels.INFO)

  vim.system(cmd, { text = true, timeout = 5000 }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local msg = string.format(
          "Citation fetch failed!\nCommand: %s\nExit code: %s\nStdout: %s\nStderr: %s\n\nIs bun installed? Run `bun --version`\nIs the URL valid? Check network connectivity.",
          table.concat(cmd, " "),
          tostring(result.code),
          result.stdout or "",
          result.stderr or ""
        )
        vim.notify(msg, vim.log.levels.ERROR)
        return
      end
      vim.notify("Citation added!", vim.log.levels.INFO)
      M.pick_citation()
    end)
  end)
end

--- Prompt for URL and fetch citation
function M.fetch_and_insert()
  vim.ui.input({ prompt = "Citation URL: " }, function(url)
    if not url or url == "" then
      return
    end
    fetch_citation(url)
  end)
end

--- Fetch citation from system clipboard
function M.fetch_from_clipboard()
  local url = vim.fn.getreg("+")
  if not url or url == "" then
    vim.notify("Clipboard is empty", vim.log.levels.WARN)
    return
  end
  url = vim.trim(url)
  vim.notify("Fetching citation from clipboard: " .. url, vim.log.levels.INFO)
  fetch_citation(url)
end

-- Export for testing
M._find_references_json = find_references_json
M._parse_csl_json = parse_csl_json
M._csl_to_display = csl_to_display

return M
