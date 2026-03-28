-- Citation module tests
-- Run with: nvim --headless -u init.lua -c "luafile lua/utils/citations_test.lua" -c "qa!"
local citations = require("utils.citations")

local pass, fail = 0, 0
local function assert_eq(got, expected, msg)
  if got == expected then
    pass = pass + 1
  else
    fail = fail + 1
    print(string.format("FAIL: %s\n  expected: %s\n  got:      %s", msg, tostring(expected), tostring(got)))
  end
end

local function assert_truthy(val, msg)
  if val then
    pass = pass + 1
  else
    fail = fail + 1
    print(string.format("FAIL: %s (got falsy)", msg))
  end
end

-- Test parse_csl_json with the existing fixture
local fixture = vim.fn.stdpath("config") .. "/scripts/bun-citations/references.json"
local items, err = citations._parse_csl_json(fixture)
assert_eq(err, nil, "parse_csl_json should not error on valid file")
assert_truthy(items and #items > 0, "parse_csl_json should return items")
if items and items[1] then
  assert_truthy(items[1].id, "first item should have an id")
  assert_truthy(items[1].title, "first item should have a title")
end

-- Test parse_csl_json with nonexistent file
local _, err2 = citations._parse_csl_json("/tmp/nonexistent_citations_test.json")
assert_truthy(err2, "parse_csl_json should error on missing file")

-- Test csl_to_display
local display = citations._csl_to_display({
  id = "https://example.com",
  title = "Test Title",
  author = { { literal = "Smith" } },
  issued = { ["date-parts"] = { { 2024 } } },
})
assert_eq(display, "[@https://example.com] — Test Title (Smith, 2024)", "csl_to_display formatting")

-- Test csl_to_display with family name
local display2 = citations._csl_to_display({
  id = "doi:123",
  title = "Paper",
  author = { { family = "Jones", given = "Bob" } },
  issued = { ["date-parts"] = { { 2023 } } },
})
assert_eq(display2, "[@doi:123] — Paper (Jones, 2023)", "csl_to_display with family name")

-- Test find_references_json
local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")
local tf = io.open(tmpdir .. "/references.json", "w")
tf:write("[]")
tf:close()
local found = citations._find_references_json(tmpdir)
assert_eq(found, tmpdir .. "/references.json", "find_references_json should find references.json")
vim.fn.delete(tmpdir, "rf")

-- Test parse_fetched_id extracts ID from bun stdout
local sample_stdout = [==[Added "LoRA" to /tmp/references.json
[
  {
    "type": "article",
    "id": "https://doi.org/10.48550/arxiv.2106.09685",
    "title": "LoRA"
  }
]]==]
assert_eq(
  citations._parse_fetched_id(sample_stdout),
  "https://doi.org/10.48550/arxiv.2106.09685",
  "parse_fetched_id extracts id from stdout"
)

-- parse_fetched_id returns nil on garbage
assert_eq(citations._parse_fetched_id("no json here"), nil, "parse_fetched_id returns nil on non-JSON")

-- parse_fetched_id handles scraped webpage output
local scraped_stdout = [==[Added "Wikipedia" to /tmp/references.json
[
  {
    "id": "https://en.wikipedia.org/wiki/Test",
    "type": "webpage",
    "title": "Test - Wikipedia"
  }
]]==]
assert_eq(
  citations._parse_fetched_id(scraped_stdout),
  "https://en.wikipedia.org/wiki/Test",
  "parse_fetched_id works with scraped webpage"
)

--------------------------------------------------------------------------------
-- Smoke tests: verify the module works inside Neovim runtime
--------------------------------------------------------------------------------

-- Module exports all expected public functions
assert_truthy(type(citations.fetch_and_insert) == "function", "fetch_and_insert is a function")
assert_truthy(type(citations.pick_citation) == "function", "pick_citation is a function")
assert_truthy(type(citations.fetch_from_clipboard) == "function", "fetch_from_clipboard is a function")

-- Neovim APIs used by the module exist
assert_truthy(type(vim.system) == "function", "vim.system is available")
assert_truthy(type(vim.ui.input) == "function", "vim.ui.input is available")
assert_truthy(type(vim.ui.select) == "function", "vim.ui.select is available")
assert_truthy(type(vim.notify) == "function", "vim.notify is available")
assert_truthy(type(vim.api.nvim_put) == "function", "vim.api.nvim_put is available")
assert_truthy(type(vim.fn.getreg) == "function", "vim.fn.getreg is available")

-- vim.json.decode works (used in parse_csl_json and parse_fetched_id)
local decoded = vim.json.decode('[{"id":"test"}]')
assert_eq(decoded[1].id, "test", "vim.json.decode works for CSL-JSON")

-- bun binary is reachable
assert_eq(vim.fn.executable("bun"), 1, "bun is executable on PATH")

-- The bun-citations script exists
local script = vim.fn.stdpath("config") .. "/scripts/bun-citations/index.ts"
assert_eq(vim.fn.filereadable(script), 1, "scripts/bun-citations/index.ts exists")

-- pick_citation with no references.json warns gracefully
local old_notify = vim.notify
local notified_msg = nil
vim.notify = function(msg, _) notified_msg = msg end
local saved_cwd = vim.fn.getcwd()
vim.cmd("cd /tmp")
citations.pick_citation()
vim.cmd("cd " .. vim.fn.fnameescape(saved_cwd))
vim.notify = old_notify
assert_truthy(notified_msg and notified_msg:find("No CSL%-JSON"), "pick_citation warns when no references file found")

-- insert_cite_key inserts text and leaves cursor after it
vim.cmd("enew!")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "before after" })
vim.api.nvim_win_set_cursor(0, { 1, 7 }) -- cursor on 'a' of 'after'
citations._insert_cite_key("https://example.com")
local line = vim.api.nvim_get_current_line()
assert_truthy(line:find("%[@https://example%.com%]"), "insert_cite_key inserts [@id] into buffer")
local cursor = vim.api.nvim_win_get_cursor(0)
-- nvim_put with last arg true places cursor after inserted text
-- cursor[2] is 0-indexed byte offset; find the ] and check cursor is past it
-- cursor[2] is 0-indexed; Lua find is 1-indexed
-- After inserting "[@https://example.com]" (22 chars) at col 7, cursor should be at 7+22=29
local expected_col = 7 + #"[@https://example.com]"
assert_eq(cursor[2], expected_col, "cursor is positioned after the closing ]")

-- pick_citation with valid references.json calls vim.ui.select with correct items
local tmp2 = vim.fn.tempname()
vim.fn.mkdir(tmp2, "p")
local rf = io.open(tmp2 .. "/references.json", "w")
rf:write('[{"id":"https://example.com","title":"Test","author":[{"literal":"Auth"}],"issued":{"date-parts":[  [2024]]}}]')
rf:close()
local select_items = nil
local old_select = vim.ui.select
vim.ui.select = function(items_arg, _, _) select_items = items_arg end
vim.cmd("cd " .. vim.fn.fnameescape(tmp2))
citations.pick_citation()
vim.cmd("cd " .. vim.fn.fnameescape(saved_cwd))
vim.ui.select = old_select
vim.fn.delete(tmp2, "rf")
assert_truthy(select_items and #select_items == 1, "pick_citation passes items to vim.ui.select")
assert_eq(select_items[1].id, "https://example.com", "pick_citation passes correct id")

-- Summary
print(string.format("\n%d passed, %d failed", pass, fail))
if fail > 0 then
  os.exit(1)
end
