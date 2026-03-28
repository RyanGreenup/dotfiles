-- * Abbreviations
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local function next_footnote_num()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local max = 0
    for _, line in ipairs(lines) do
        for num in line:gmatch("%[%^(%d+)%]") do
            local n = tonumber(num)
            if n and n > max then max = n end
        end
    end
    return tostring(max + 1)
end

return {
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

    -- Footnote: inserts [^N] at cursor and [^N]: definition below
    -- Uses dynamic node to compute number once, rep to mirror it
    s("fn", {
        t("[^"),
        d(1, function() return sn(nil, { i(1, next_footnote_num()) }) end),
        t("]"),
        i(0),
        t({ "", "", "[^" }), rep(1), t("]: "),
        i(2, "footnote text"),
    }),

}
