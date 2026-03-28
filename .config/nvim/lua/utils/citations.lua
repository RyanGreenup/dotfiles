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

--- Insert [@id] at cursor and move cursor after it
---@param id string
local function insert_cite_key(id)
  local text = "[@" .. id .. "]"
  vim.api.nvim_put({ text }, "", false, true)
end

--- Extract the citation ID from bun stdout (parses the "Added ... to ..." line)
---@param stdout string
---@return string|nil
local function parse_fetched_id(stdout)
  -- CSL-JSON output: Added "Title" to path — re-read the file to get the ID
  -- The stdout contains the JSON of new items after the "Added" line
  local json_start = stdout:find("%[%s*{")
  if not json_start then
    return nil
  end
  local json_str = stdout:sub(json_start)
  local ok, items = pcall(vim.json.decode, json_str)
  if ok and type(items) == "table" and items[1] and items[1].id then
    return items[1].id
  end
  return nil
end

--- Select a citation from existing references via vim.ui.select and insert it
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

  local display_items = {}
  for _, item in ipairs(items) do
    table.insert(display_items, { display = csl_to_display(item), id = item.id })
  end

  vim.ui.select(display_items, {
    prompt = "Insert citation:",
    format_item = function(entry) return entry.display end,
  }, function(choice)
    if choice then
      insert_cite_key(choice.id)
    end
  end)
end

--- Run the bun citation fetcher, insert the key directly on success
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
      local id = parse_fetched_id(result.stdout or "")
      if id then
        insert_cite_key(id)
        vim.notify("Citation inserted: [@" .. id .. "]", vim.log.levels.INFO)
      else
        vim.notify("Citation added but could not extract ID from output", vim.log.levels.WARN)
      end
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
M._insert_cite_key = insert_cite_key
M._parse_fetched_id = parse_fetched_id

return M
