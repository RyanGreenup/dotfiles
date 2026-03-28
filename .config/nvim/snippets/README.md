# Snippets

Two snippet directories, two formats, loaded by LuaSnip (`lua/config/luasnip.lua`).

## `snippets/` — SnipMate format

Simple text-based snippets. One file per filetype: `<filetype>.snippets`.

```snippets
# comment
snippet trigger "Description"
	snippet body with $1 tabstops and $0 final cursor
	mirrored tabstop: $1
```

- Indentation: **one real tab** before each body line.
- `$1`, `$2`, ... are tabstops. `$0` is the final cursor position.
- `${1:default}` for default text. `$1` elsewhere mirrors it.
- `extends python` at the top to inherit another filetype's snippets.
- `priority 100` to set priority (higher wins on same trigger).

Create a new file: `snippets/<filetype>.snippets`

## `LuaSnip/` — Native Lua format

Full programmatic control: function nodes, choice nodes, dynamic nodes, autosnippets.

Files go in `LuaSnip/<filetype>/<filetype>.lua` and return a table of snippets:

```lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta  -- uses <> delimiters

return {
  -- Regular snippet
  s("trigger", fmt("Hello {}!", { i(1, "world") })),

  -- Autosnippet (expands immediately on typing trigger)
  s({ trig = "mk", snippetType = "autosnippet" },
    fmta("$<>$", { i(1) })
  ),

  -- Function node (derives text from another node)
  s("comp", fmt("{}\ntype {}Props = {{}}", {
    i(1, "MyComponent"),
    f(function(args) return args[1][1] end, { 1 }),
  })),
}
```

### Key node types

| Node | Import | Purpose |
|------|--------|---------|
| `t("text")` | `ls.text_node` | Static text |
| `i(n, "default")` | `ls.insert_node` | Tabstop (n=position, 0=final) |
| `f(fn, {argnode_ids})` | `ls.function_node` | Computed text from other nodes |
| `d(n, fn, {argnode_ids})` | `ls.dynamic_node` | Generates nodes dynamically |
| `c(n, {nodes...})` | `ls.choice_node` | Cycle between alternatives |
| `sn(nil, {nodes...})` | `ls.snippet_node` | Group of nodes (used inside `d()`) |

### Tips

- `fmta` uses `<>` as placeholder delimiters (good when snippet contains `{}`).
- `fmt` uses `{}` as placeholder delimiters.
- Autosnippets require `enable_autosnippets = true` in LuaSnip config (already set).
- Browse all snippets: `<leader>sn` or `:Telescope luasnip`
