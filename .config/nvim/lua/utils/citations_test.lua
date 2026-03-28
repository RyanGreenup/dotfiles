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

--------------------------------------------------------------------------------
-- Smoke tests: verify the module works inside Neovim runtime
--------------------------------------------------------------------------------

-- Module exports all expected public functions
assert_truthy(type(citations.fetch_and_insert) == "function", "fetch_and_insert is a function")
assert_truthy(type(citations.pick_citation) == "function", "pick_citation is a function")
assert_truthy(type(citations.fetch_from_clipboard) == "function", "fetch_from_clipboard is a function")

-- vim.system exists (used for async fetch)
assert_truthy(type(vim.system) == "function", "vim.system is available")

-- vim.ui.input exists (used for URL prompt)
assert_truthy(type(vim.ui.input) == "function", "vim.ui.input is available")

-- vim.notify exists (used for progress/error feedback)
assert_truthy(type(vim.notify) == "function", "vim.notify is available")

-- vim.api.nvim_put exists (used to insert citation at cursor)
assert_truthy(type(vim.api.nvim_put) == "function", "vim.api.nvim_put is available")

-- vim.json.decode works (used in parse_csl_json)
local decoded = vim.json.decode('[{"id":"test"}]')
assert_eq(decoded[1].id, "test", "vim.json.decode works for CSL-JSON")

-- vim.fn.getreg exists (used for clipboard in fetch_from_clipboard)
assert_truthy(type(vim.fn.getreg) == "function", "vim.fn.getreg is available")

-- Telescope modules load (these are needed by pick_citation)
local tel_ok, _ = pcall(require, "telescope.pickers")
assert_truthy(tel_ok, "telescope.pickers loads")
local find_ok, _ = pcall(require, "telescope.finders")
assert_truthy(find_ok, "telescope.finders loads")
local act_ok, _ = pcall(require, "telescope.actions")
assert_truthy(act_ok, "telescope.actions loads")
local state_ok, _ = pcall(require, "telescope.actions.state")
assert_truthy(state_ok, "telescope.actions.state loads")

-- bun binary is reachable
local bun_check = vim.fn.executable("bun")
assert_eq(bun_check, 1, "bun is executable on PATH")

-- The bun-citations script exists
local script = vim.fn.stdpath("config") .. "/scripts/bun-citations/index.ts"
assert_eq(vim.fn.filereadable(script), 1, "scripts/bun-citations/index.ts exists")

-- pick_citation with no references.json in /tmp doesn't crash (just notifies)
local old_notify = vim.notify
local notified_msg = nil
vim.notify = function(msg, _) notified_msg = msg end
local saved_cwd = vim.fn.getcwd()
vim.cmd("cd /tmp")
citations.pick_citation()
vim.cmd("cd " .. vim.fn.fnameescape(saved_cwd))
vim.notify = old_notify
assert_truthy(notified_msg and notified_msg:find("No CSL%-JSON"), "pick_citation warns when no references file found")

-- pick_citation with a valid references.json opens without error
-- (Telescope picker will fail headless but we verify it gets past parsing)
local tmp2 = vim.fn.tempname()
vim.fn.mkdir(tmp2, "p")
local rf = io.open(tmp2 .. "/references.json", "w")
rf:write('[{"id":"https://example.com","title":"Test","author":[{"literal":"Auth"}],"issued":{"date-parts":[[2024]]}}]')
rf:close()
local pick_err = nil
vim.cmd("cd " .. vim.fn.fnameescape(tmp2))
-- Telescope may error in headless, but parsing should succeed
local pick_ok, pick_result = pcall(citations.pick_citation)
vim.cmd("cd " .. vim.fn.fnameescape(saved_cwd))
vim.fn.delete(tmp2, "rf")
-- If it errors, it should be a Telescope display issue, not a parse issue
if not pick_ok then
  assert_truthy(
    not tostring(pick_result):find("JSON parse error"),
    "pick_citation failure is not a parse error (Telescope headless limitation is OK)"
  )
else
  pass = pass + 1 -- it worked fully, great
end

-- Summary
print(string.format("\n%d passed, %d failed", pass, fail))
if fail > 0 then
  os.exit(1)
end
