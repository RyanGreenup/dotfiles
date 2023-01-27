-- * Abbreviations
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

-- {{{1 Snippets
-- {{{2 Create Empty Table
local snippets = {}
--{{{2 Headings
local function headings()
  local headers = {
    { trig = "ff", text = "====== <> ======" },
    { trig = "h1", text = "====== <> ======" },
    { trig = "h2", text = "===== <> =====" },
    { trig = "h3", text = "==== <> ====" },
    { trig = "h4", text = "=== <> ===" },
    { trig = "h5", text = "== <> ==" }
  }


  for _, header in ipairs(headers) do
    table.insert(snippets, s({ trig = header.trig }, fmta(header.text, { i(1) })))
  end
end
--{{{2 Others
local function other_snippets()
  local other_snippets = {

    s({ trig = ";a", snippetType = "autosnippet" },
      {
        t("\\alpha"),
      }
    ),

    s({ trig = ";b", snippetType = "autosnippet" },
      {
        t("\\beta"),
      }
    ),

  }

  for _, snippet in ipairs(other_snippets) do
    table.insert(snippets, snippet)
  end
end
--{{{1 Call the functions for the snippets desired
headings()
other_snippets()
--{{{1 Returned snippets
return snippets
