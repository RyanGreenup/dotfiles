-- * Abbreviations
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta


return {

  s({
      trig = "det",
      dscr = "Create a Details dialog",
    },
    {
      t({"<details><summary>", "", ""}),
      i(1),
      t({"</summary>", "", ""}),
      i(2),
      t({"</details>", ""}),
    }),
  s({ trig = "qk", snippetType = "autosnippet" },
    fmta(
      [[
    ```{<>}
    <>
    ```

    ]],
      {
        i(1),
        i(2),
      }
    )
  ),

  s({ trig = "pyqk", snippetType = "autosnippet" },
    fmta(
      [[
    ```{python}
    <>
    ```

    ]],
      {
        i(1),
      }
    )
  ),

  s({ trig = "rqk", snippetType = "autosnippet" },
    fmta(
      [[
    ```{r}
    <>
    ```

    ]],
      {
        i(1),
      }
    )
  ),

}
