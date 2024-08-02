local wk = require("which-key")

-- TODO decide on autocommand keymaps
-- for markdown and slime
-- Keybindings aim for some degree of consistency with
-- [Mappings](https://docs.astronvim.com/mappings)

local n = require('notify')

local theme = "ivy" -- Allowed: dropdown, ivy, ...
function telescope_command(s, s2)
  local command = "<cmd>" .. s .. " theme=" .. theme .. "<cr>"
  return { command, s2 }
end

wk.add({
  { "<leader><leader>", function() require('telescope.builtin').find_files() end, desc = "fzf" },

  { "<leader>w",        proxy = "<c-w>",                                          group = "windows" }, -- proxy to window mappings
  {
    "<leader>b",
    group = "buffers",
    expand = function()
      return require("which-key.extras").expand.buf()
    end
  },
})

-- D Debug
wk.add({
  { "<leader>d", group = "Debug" }, -- group
  {
    { "<leader>dt", function() require('dapui').toggle() end,          desc = "Info" },
    { "<leader>db", function() require('dap').toggle_breakpoint() end, desc = "Breakpoint" },
    { "<leader>dc", function() require 'dap'.continue() end,           desc = "Continue" },
    { "<leader>dC", function() require 'dap'.run_to_cursor() end,      desc = "Run to Cursor" },
    { "<leader>di", function() require 'dap'.step_into() end,          desc = "In (Step)" },
    { "<leader>dj", function() require 'dap'.down() end,               desc = "Down" },
    { "<leader>dk", function() require 'dap'.up() end,                 desc = "Up" },
    { "<leader>dl", function() require 'dap'.run_last() end,           desc = "Run Last" },
    { "<leader>do", function() require 'dap'.step_out() end,           desc = "Out (Step)" },
    { "<leader>dO", function() require 'dap'.step_over() end,          desc = "Over (Step)" },
    { "<leader>dp", function() require 'dap'.pause() end,              desc = "Pause" },
    { "<leader>di", function() require 'dap'.session() end,            desc = "Session" },
    { "<leader>dq", function() require 'dap'.terminate() end,          desc = "Quit (Terminate)" },
  }
})

-- L LSP
wk.add({
  { "<leader>l", group = "LSP" }, -- group
  {
    mode = { "n", "v" },
    { "<leader>la",  function() vim.lsp.buf.code_action() end,     desc = "Code Action" },
    { "<leader>li",  function() vim.cmd [[LspInfo]] end,           desc = "LSP Info" },
    { "<leader>lh",  function() vim.lsp.buf.signature_help() end,  desc = "Signature Help" },
    { "<leader>lr",  function() vim.lsp.buf.rename() end,          desc = "Rename Symbol" },
    { "<leader>lf",  function() vim.lsp.buf.format() end,          desc = "Format" },
    { "<leader>ld",  function() vim.diagnostic.goto_next() end,    desc = "Diagnostic" },
    { "<leader>lo",  group = "Otter" },
    { "<leader>loa", function() require('otter').activate() end,   desc = "Activate" },
    { "<leader>lod", function() require('otter').deactivate() end, desc = "Deactivate" },
    { "<leader>gD",  function() vim.lsp.buf.declaration() end,     desc = "LSP Declaration" },
    { "<leader>gD",  function() vim.lsp.buf.definition() end,      desc = "LSP Declaration" },
    { "<leader>gy",  function() vim.lsp.buf.type_definition() end, desc = "LSP Type Definition" },
    {
      "<leader>grr",
      function()
        -- vim.lsp.buf.references()
        require('telescope.builtin').lsp_references()
      end,
      desc = "LSP Declaration",
      mode = "n"
    },
    {
      "<leader>lG",
      function()
        -- vim.lsp.buf.document_symbol()
        require('telescope.builtin').lsp_workspace_symbols()
      end,
      desc = "Workspace Symbols",
      mode = "n"
    },
    {
      "<leader>ls",
      function()
        -- vim.lsp.buf.document_symbol()
        require('telescope.builtin').lsp_document_symbols()
      end,
      desc = "Document Symbols",
      mode = "n"
    },
  }
})



-- B Buffers
wk.add({
  { "<leader>b", group = "Buffers" }, -- group
  {
    { "<leader>bd", function() vim.api.nvim_buf_delete(0, { force = true }) end, desc = "Delete", mode = "n" },
    { "<leader>bp", function() vim.cmd [[bp]] end,                               desc = "Delete", mode = "n" },
    { "<leader>bn", function() vim.cmd [[bn]] end,                               desc = "Delete", mode = "n" },
    { "<leader>bb", function() require('telescope.builtin').buffers() end,       desc = "Delete", mode = "n" },
    -- { "<leader>bp",  function()  end, desc = "Delete", mode = "n" },
  }
})


-- S Search
wk.add({
  { "<leader>s", group = "Search" }, -- group
  {
    { "<leader>ss", function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = "Delete", mode = "n" },
  }
})

-- LaTeX
function Which_key_modal_bind()
  if Which_key_mode == nil then
    Which_key_mode = "none"
  end
  if Which_key_mode == "none" then
    -- TODO is there a way to make this more dynamic?
    vim.cmd [[source ~/.config/nvim/lua/plugins/which-key.lua]]
  elseif Which_key_mode == "latex" then
    wk.add({
      { "q", function() Which_key_mode = "normal" end, desc = "Quit" },
      {
        mode = { "i", "n" },
        { "dm", function() n('Hello') end, desc = "Quit", cond = Which_key_mode == "latex" },
      }
    })
  end
end

local function Revert_all_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= nil then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("e!")
      end)
    end
  end
end

local notes_dir = "~/Notes/slipbox/"
-- F Files
wk.add({
  { "<leader>f", group = "Why" }, -- group
  {
    { "<leader>ff",  "<cmd>Telescope find_files<cr>",                      desc = "Find File", mode = "n" },
    { "<leader>fo",  group = "Open" }, -- group
    { "<leader>foc", function() vim.cmd('edit' .. vim.fn.getreg('+')) end, desc = "Clipboard", mode = "n" },
    {
      "<leader>fon",
      function()
        vim.cmd('edit' .. notes_dir .. "home.md")
        vim.cmd('cd' .. notes_dir)
      end,
      desc = "Clipboard",
      mode = "n"
    },
    { "<leader>fs", function() vim.cmd [[w]] end,         desc = "Save",           mode = "n" },
    { "<leader>fe", function() vim.cmd [[e!]] end,        desc = "Revert",         mode = "n" },
    { "<leader>fE", function() Revert_all_buffers() end,  desc = "Revert",         mode = "n" },
    { "<leader>fg", function() vim.cmd [[:cd %:p:h]] end, desc = "Go to File Dir", mode = "n" },
    {
      "<leader>fr",
      function()
        require('telescope.builtin').oldfiles()
      end,
      desc = "Recent"
    },
    {
      "<leader>ft",
      function()
        require('telescope.builtin').filetypes()
      end,
      desc = "File Types"
    },
    {
      "<leader>fy",
      function()
        vim.fn.setreg('+', vim.api.nvim_buf_get_name(0))
      end,
      desc = "Copy Path"
    },
    {
      "<leader>fY",
      function()
        vim.fn.setreg('+', vim.api.nvim_buf_get_name(0))
      end,
      desc = "Copy Path"
    },
    {
      "<leader>fp",
      function()
        vim.cmd('edit ' .. '~/.config/nvim/init.lua')
        vim.cmd('cd' .. '~/.config/nvim/lua')
      end,
      desc = "Edit Config"
    }
  }
})


-- Notes

wk.add({
  {
    { "<leader>n",  group = "Notes" }, -- group
    { "<leader>nb", require("utils/markdown_babel").send_code, desc = "Execute a markdown cell and include output"},
    { "<leader>nl", function() Insert_notes_link_alacritty_fzf() end, desc = "Insert Notes Link" },
    { "<leader>nL", function() Insert_notes_link() end,               desc = "Insert Notes Link" },
    { "<leader>ns", function() Create_markdown_link(true) end,        desc = "Create a Subpage Link and Open Buffer" },
    { "<leader>nS", function() Create_markdown_link() end,            desc = "Create a Link From text and Open Buffer" },
    { "<leader>nu", function() Format_url_markdown() end,             desc = "Format a URL as a Markdown Link" },
    { "<leader>nv", function() Generate_navigation_tree() end,        desc = "Generate Navigation Tree" },
    { "<leader>nr", function() RenderMarkdownToggle() end,            desc = "Render Markdown Toggle" },
    { "<leader>np", function() Paste_png_image()() end,               desc = "Paste Image from Clipboard" },
    { "<leader>na", function() Attach_file()() end,                   desc = "Prompt User to attach file under ./assets" },
    { "<leader>nz", function() Search_notes_fzf()() end,              desc = "Search Notes using Embeddings" },
    { "<leader>nj", group = "Notes" }, -- group
  }
})


wk.add({
  { "<leader>j",  group = "Jupyter Notebook" }, -- group
  { "<leader>jj", require('utils/notebooks').jupytext_set_formats,  desc = "Jupytext Pair" },
  { "<leader>jp", require('utils/notebooks').quarto_preview,                  desc = "Jupytext Pair" },
  { "<leader>js", require('utils/notebooks').jupytext_sync,                   desc = "Jupytext Sync" },
  { "<leader>jw", require('utils/notebooks').jupytext_watch_sync,             desc = "Watch Sync" },
  { "<leader>jo", require('utils/notebooks').open_in_vscode,           desc = "Open in VSCode" },
  { "<leader>jm", require('utils/notebooks').jupytext_render_markdown,    desc = "Export to Markdown (Quarto)" },
  { "<leader>jM", require('utils/notebooks').jupytext_render_markdown,   desc = "Export to Markdown (Jupyter)" },
  { "<leader>jv", group = "View" }, -- subgroup for view commands
  {
    { "<leader>jvm", function() vim.cmd [[:vsplit %:r.md]] end, desc = "Markdown" },
    { "<leader>jvn", function() vim.cmd [[:vsplit %:r.Rmd]] end, desc = "Rmd" },
    { "<leader>jvp", function() vim.cmd [[:vsplit %:r.py]] end, desc = "Python" },
    { "<leader>jvr", function() vim.cmd [[:vsplit %:r.r]] end, desc = "Python" },
    { "<leader>jvj", function() vim.cmd [[:vsplit %:r.jl]] end, desc = "Julia" },
    { "<leader>jvs", function() vim.cmd [[:vsplit %:r.rs]] end, desc = "Rust" },
    { "<leader>jvi", function() vim.cmd [[:vsplit %:r.ipynb]] end, desc = "⚠ ipynb" },
  }
})


-- v Vim
wk.add({

  { "<leader>v", group = "Help" }, -- group
  {
    {
      "<leader>ht",

      function()
        require('telescope.builtin').colorscheme()
      end,
      desc = "Theme",
      mode = "n"
    },
    {
      "<leader>hp",
      "<cmd>Telescope lazy<CR>",
      desc = "Packages",
      mode = "n"
    },
  }
})


-- v Vim
wk.add({

  { "<leader>v", group = "Vim" }, -- group
  {
    { "<leader>vs", "<cmd>so %<cr>", desc = "Find File", mode = "n" },
    -- { "<leader>vm",  group = "Mode" },
    -- { "<leader>vml", function() vim.cmd [[source /tmp/file.lua]] end, desc = "LaTeX Mode" }
  }
})
