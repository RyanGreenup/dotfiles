-- Abbreviations
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

-- Create a table for snippets
local snippets = {}

-- {{{1 Snippets
-- {{{2 Headings
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
-- }}}2
-- Other Snippets
-- {{{2 Folding Heading
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
-- }}}2

--}}}1

-- Call the functions for the snippets desired
headings()
other_snippets()

-- Returned snippets
return snippets
