local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Derive a PascalCase component name from the current filename
local function filename_to_component(_, snip)
  local name = vim.fn.fnamemodify(snip.env.TM_FILENAME, ":t:r") -- strip path + extension
  if name == "index" then
    -- use parent directory name instead
    name = vim.fn.fnamemodify(snip.env.TM_FILEPATH, ":h:t")
  end
  -- PascalCase: capitalize first letter
  return name:sub(1, 1):upper() .. name:sub(2)
end

--- Use treesitter to extract prop names from the interface above the cursor.
--- Finds the nearest interface_declaration ancestor/sibling and reads its
--- property_signature children.
local function get_props_from_interface(interface_node)
  local props = {}
  for child in interface_node:iter_children() do
    -- object_type contains the property_signature nodes
    if child:type() == "object_type" then
      for prop in child:iter_children() do
        if prop:type() == "property_signature" then
          local name_node = prop:child(0)
          if name_node then
            local text = vim.treesitter.get_node_text(name_node, 0)
            if text then
              props[#props + 1] = text
            end
          end
        end
      end
    end
  end
  return props
end

--- Function node: after the interface tabstop is filled, parse the buffer
--- and extract prop names to build the destructured parameter list.
local function destructured_props(args, _snip)
  -- Try treesitter first
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "tsx")
  if ok and parser then
    local trees = parser:parse()
    if trees and trees[1] then
      local root = trees[1]:root()
      -- Find interface declarations matching {ComponentName}Props
      local query_str = '(interface_declaration name: (type_identifier) @name)'
      local query_ok, query = pcall(vim.treesitter.query.parse, "tsx", query_str)
      if query_ok then
        local target_name = args[1][1] .. "Props"
        for _, node, _ in query:iter_captures(root, 0) do
          local text = vim.treesitter.get_node_text(node, 0)
          if text == target_name then
            local interface_node = node:parent()
            local props = get_props_from_interface(interface_node)
            if #props > 0 then
              return table.concat(props, ", ")
            end
          end
        end
      end
    end
  end
  return ""
end

--------------------------------------------------------------------------------
-- Solid.js Component Snippets
--------------------------------------------------------------------------------

return {

  -- Basic component: function, no props
  s("sfc", fmt([[
import type {{ JSX }} from "solid-js/jsx-runtime";

{}function {}(): JSX.Element {{
  return (
    <div>
      {}
    </div>
  );
}}
]], {
    c(1, { t("export default "), t("") }),
    d(2, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(0),
  })),

  -- Component with props + treesitter destructuring
  s("sfcp", fmt([[
import type {{ JSX }} from "solid-js/jsx-runtime";

interface {}Props {{
  {}: {};
}}

{}function {}(props: {}Props): JSX.Element {{
  return (
    <div>
      {{props.{}}}
      {}
    </div>
  );
}}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(2, "label"),
    i(3, "string"),
    c(4, { t("export default "), t("") }),
    rep(1),
    rep(1),
    rep(2),
    i(0),
  })),

  -- Component with children
  s("sfcc", fmt([[
import type {{ ParentProps }} from "solid-js";
import type {{ JSX }} from "solid-js/jsx-runtime";

{}function {}(props: ParentProps): JSX.Element {{
  return (
    <div>
      {{props.children}}
      {}
    </div>
  );
}}
]], {
    c(1, { t("export default "), t("") }),
    d(2, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(0),
  })),

  -- Component with props and children
  s("sfcpc", fmt([[
import type {{ ParentProps }} from "solid-js";
import type {{ JSX }} from "solid-js/jsx-runtime";

interface {}Props {{
  {}: {};
}}

{}function {}(props: ParentProps<{}Props>): JSX.Element {{
  return (
    <div>
      {{props.{}}}
      {{props.children}}
      {}
    </div>
  );
}}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(2, "label"),
    i(3, "string"),
    c(4, { t("export default "), t("") }),
    rep(1),
    rep(1),
    rep(2),
    i(0),
  })),

  -- Arrow const component
  s("sconst", fmt([[
import type {{ Component }} from "solid-js";

const {}: Component = () => {{
  return (
    <div>
      {}
    </div>
  );
}};

{}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(0),
    c(2, {
      sn(nil, { t("export default "), rep(1), t(";") }),
      t(""),
    }),
  })),

  -- Arrow const component with props
  s("sconstp", fmt([[
import type {{ Component }} from "solid-js";

interface {}Props {{
  {}: {};
}}

const {}: Component<{}Props> = (props) => {{
  return (
    <div>
      {{props.{}}}
      {}
    </div>
  );
}};

{}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(2, "label"),
    i(3, "string"),
    rep(1),
    rep(1),
    rep(2),
    i(0),
    c(4, {
      sn(nil, { t("export default "), rep(1), t(";") }),
      t(""),
    }),
  })),

  -- Arrow const ParentComponent with props and children
  s("sconstpc", fmt([[
import type {{ ParentComponent }} from "solid-js";

interface {}Props {{
  {}: {};
}}

const {}: ParentComponent<{}Props> = (props) => {{
  return (
    <div>
      {{props.{}}}
      {{props.children}}
      {}
    </div>
  );
}};

{}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(2, "label"),
    i(3, "string"),
    rep(1),
    rep(1),
    rep(2),
    i(0),
    c(4, {
      sn(nil, { t("export default "), rep(1), t(";") }),
      t(""),
    }),
  })),

  -- Context provider with auto-derived names
  -- Built with t/rep nodes to avoid fmt delimiter clashes with JSX/Lua braces
  s("sctx", {
    t('import { createContext, useContext, type ParentProps } from "solid-js";'), t({ "", "" }),
    t('import { createStore, type SetStoreFunction } from "solid-js/store";'), t({ "", "", "" }),
    t("interface "), d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end), t({ "State {", "  " }),
    i(2, "value"), t(": "), i(3, "string"), t({ ";", "}", "", "" }),
    t("type "), rep(1), t("Value = ["), rep(1), t("State, SetStoreFunction<"), rep(1), t({ "State>];", "", "" }),
    t("const default"), rep(1), t(": "), rep(1), t({ "State = {", "  " }),
    rep(2), t(": "), i(4, '""'), t({ ",", "};", "", "" }),
    t("const "), rep(1), t("Context = createContext<"), rep(1), t("Value>([default"), rep(1), t({ ", () => {}]);", "", "" }),
    t("export function "), rep(1), t({ "Provider(props: ParentProps) {", "" }),
    t("  const [state, setState] = createStore<"), rep(1), t("State>({ ...default"), rep(1), t({ " });", "" }),
    t({ "  return (", "    <" }), rep(1), t({ "Context.Provider value={[state, setState]}>", "" }),
    t({ "      {props.children}", "" }),
    t("    </"), rep(1), t({ "Context.Provider>", "  );", "}", "", "" }),
    t("export function use"), rep(1), t("(): "), rep(1), t({ "Value {", "" }),
    t("  return useContext("), rep(1), t({ "Context);", "}" }),
  }),

  -- Show conditional
  s("sshow", fmt([[
<Show when={{{}}} fallback={{{}}}>
  {}
</Show>
]], {
    i(1, "condition()"),
    c(2, {
      i(nil, "<span>Loading...</span>"),
      i(nil, "null"),
      sn(nil, { t("<"), i(1, "Fallback"), t(" />") }),
    }),
    i(0),
  })),

  -- For loop
  s("sfor", fmt([[
<For each={{{}}}>{{({}) =>
  {}
}}</For>
]], {
    i(1, "items()"),
    i(2, "item"),
    i(0),
  })),

  -- splitProps
  s("ssplit", fmt([[
const [{}, others] = splitProps(props, [{}]);
]], {
    i(1, "local"),
    i(2, '"class"'),
  })),

  -- TanStack file route
  s("sroute", fmt([[
import {{ createFileRoute }} from "@tanstack/solid-router";
import type {{ JSX }} from "solid-js/jsx-runtime";

export const Route = createFileRoute("/{}")({{
  component: {},
}});

function {}(): JSX.Element {{
  return (
    <main>
      {}
    </main>
  );
}}
]], {
    i(1, "path"),
    d(2, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip) .. "Page") })
    end),
    rep(2),
    i(0),
  })),

  -- Component with treesitter prop destructuring (advanced)
  -- Type the interface first, then tab to the function — props auto-fill
  s("sfcx", fmt([[
import type {{ JSX }} from "solid-js/jsx-runtime";

interface {}Props {{
  {}
}}

export default function {}({{{}}}: {}Props): JSX.Element {{
  return (
    <div>
      {}
    </div>
  );
}}
]], {
    d(1, function(_, snip)
      return sn(nil, { i(1, filename_to_component(nil, snip)) })
    end),
    i(2, "// props"),
    rep(1),
    f(destructured_props, { 1 }),
    rep(1),
    i(0),
  })),
}
