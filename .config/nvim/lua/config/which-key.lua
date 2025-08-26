local wk = require("which-key")

-- TODO decide on autocommand keymaps
-- for markdown and slime
-- Keybindings aim for some degree of consistency with
-- [Mappings](https://docs.astronvim.com/mappings)

local n = require('notify')

local theme = "ivy" -- Allowed: dropdown, ivy, ...
wk.add({
  { "<leader><leader>", require('telescope.builtin').find_files, desc = "fzf" },
  { "<leader>'",        require('telescope.builtin').resume,     desc = "fzf" },
  { "<leader>/",        require('telescope.builtin').live_grep,  desc = "fzf" },

  { "<leader>w",        proxy = "<c-w>",                         group = "windows" }, -- proxy to window mappings
  { "<leader>wo",       "<cmd>wincmd |<CR><cmd>wincmd _<CR>",    desc = "Maximize" },
  { "<leader>wO",       "<cmd>only<CR>",                         desc = "Only Window" },
  { "<leader>wt",       group = "Tabs" },
  {
    { "<leader>wte", "<cmd>tabedit<CR>",                  desc = "Edit Tab",           mode = "n" },
    { "<leader>wtx", "<cmd>tabclose<CR>",                 desc = "Close Tab",          mode = "n" },
    { "<leader>wtp", "<cmd>tabnext<CR>",                  desc = "Previous Tab",       mode = "n" },
    { "<leader>wtn", "<cmd>tabprevious<CR>",              desc = "Next Tab",           mode = "n" },
    { "<leader>wto", "<cmd>tabedit<CR>",                  desc = "Open Tab",           mode = "n" },
    { "<leader>wtm", "<cmd>lua Move_window_to_tab()<CR>", desc = "Move Window to Tab", mode = "n" }
  },
})



---comment
---@return string
local avante_complete_code = function()
  return 'Complete the following codes written in ' .. vim.bo.filetype
end


-- prefil edit window with common scenarios to avoid repeating query and submit immediately
local prefill_edit_window = function(request)
  require('avante.api').edit()
  local code_bufnr = vim.api.nvim_get_current_buf()
  local code_winid = vim.api.nvim_get_current_win()
  if code_bufnr == nil or code_winid == nil then
    return
  end
  vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  -- Optionally set the cursor position to the end of the input
  vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  -- Simulate Ctrl+S keypress to submit
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
end

wk.add({
  mode = { 'n', 'v' },
  { "<leader>a", group = "LLM" }, -- group
  {
    { "<leader>az", function() require('utils/telescope_stream_ollama_model').choose_model() end, desc = "Choose model for Ollama Completion with <Insert>" },
    -- https://github.com/yetone/avante.nvim/wiki/Recipe-and-Tricks#advanced-shortcuts-for-frequently-used-queries-756
    {
      '<leader>ac',
      function()
        require('avante.api').ask { question = avante_complete_code() }
      end,
      desc = 'Complete Code(ask)',
    },

    {
      '<leader>aC',
      function()
        prefill_edit_window(avante_complete_code())
      end,
      desc = 'Complete Code(edit)',
    },

  }
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
    { "<leader>la", vim.lsp.buf.code_action,                                desc = "Code Action" },
    { "<leader>li", function() vim.cmd [[LspInfo]] end,                     desc = "LSP Info" },
    { "<leader>lh", vim.lsp.buf.signature_help,                             desc = "Signature Help" },
    { "<leader>lr", vim.lsp.buf.rename,                                     desc = "Rename Symbol" },
    { "<leader>lR", "<cmd>LspRestart<CR><cmd>LspStop<CR><cmd>LspStart<CR>", desc = "Rename Symbol" },
    { "<leader>lf", vim.lsp.buf.format,                                     desc = "Format" },
    { "<leader>ld", vim.diagnostic.goto_next,                               desc = "Diagnostic" },
    { "<leader>lo", group = "Otter" },
    {
      "<leader>lt",
      function()
        if vim.fn.has "nvim-0.10" == 1 then
          local ok = pcall(vim.lsp.inlay_hint.enable, vim.lsp.inlay_hint.is_enabled())
          if ok then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          else
            vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
          end
        end
      end,
      desc = "Toggle Inlay Type Hints"
    },
    { "<leader>loa", require('otter').activate,                          desc = "Deactivate",             cond = pcall(require, 'otter') },
    { "<leader>lod", require('otter').deactivate,                        desc = "Deactivate",             cond = pcall(require, 'otter') },
    { "<leader>gD",  vim.lsp.buf.declaration,                            desc = "LSP Declaration" },
    { "<leader>gd",  vim.lsp.buf.definition,                             desc = "LSP Declaration" },
    { "<leader>gy",  vim.lsp.buf.type_definition,                        desc = "LSP Type Definition" },
    { "<leader>gi",  vim.lsp.buf.implementation,                         desc = "LSP Type Implementation" },
    { "<leader>gr",  vim.lsp.buf.references,                             desc = "LSP Type Implementation" },
    -- vim.lsp.buf.references()
    { "<leader>si",  require('telescope.builtin').lsp_document_symbols,  desc = "Document Symbols" },
    { "<leader>sI",  require('telescope.builtin').lsp_workspace_symbols, desc = "Document Symbols" },
    { "<leader>sr",  require('telescope.builtin').lsp_references,        desc = "LSP Declaration" },
    -- vim.lsp.buf.document_symbol()
    { "<leader>lG",  require('telescope.builtin').lsp_workspace_symbols, desc = "Workspace Symbols" },
    -- vim.lsp.buf.document_symbol()
    { "<leader>ls",  require('telescope.builtin').lsp_document_symbols,  desc = "Document Symbols" },
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
  { "<leader>s", group = "+search" }, -- group
  {
    { "<leader>ss", function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = "Fuzzy search in current buffer", mode = "n" },
    { "<leader>sd", function() require('telescope.builtin').lsp_document_symbols() end,      desc = "LSP Document symbols",           mode = "n" },
    { "<leader>sj", "<cmd>Telescope jumplist theme=ivy<CR>",                                 desc = "Jumplist",                       mode = "n" },
    { "<leader>sD", function() require('telescope.builtin').lsp_workspace_symbols() end,     desc = "LSP workspace symbols",          mode = "n" },
    { "<leader>se", function() require('telescope.builtin').quickfix() end,                  desc = "Errors",                         mode = "n" },
    { "<leader>sr", function() require('telescope.builtin').lsp_references() end,            desc = "LSP References",                 mode = "n" },
    { "<leader>sm", function() require('telescope.builtin').marks() end,                     desc = "Marks",                          mode = "n" }
  }
})





-- LaTeX
function Which_key_modal_bind()
  if Which_key_mode == nil then
    Which_key_mode = "none"
  end
  if Which_key_mode == "none" then
    -- TODO is there a way to make this more dynamic?
    vim.cmd [[source ~/.config/nvim/lua/config/which-key.lua]]
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

local function Revert_all_buffers(cmd)
  if cmd == nil then
    cmd = "e!"
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= nil then
      -- check if file exists
      if vim.api.nvim_buf_get_name(buf) ~= "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd(cmd)
        end)
      end
    end
  end
  vim.cmd(cmd)
end


local notes_dir = "~/Notes/slipbox/"
-- F Files
wk.add({
  { "<leader>f", group = "Files" }, -- group
  {
    -- [fn_1]
    -- TODO moved this into the module, check it all
    -- ~/.config/nvim/lua/utils/markdown_toggle_autocmd_vscode.lua
    -- { "<leader>fa",  "<cmd>set autoread | au CursorHold * checktime | call feedkeys('lh')<cr>", desc = "Auto Revert",    mode = "n" },
    { "<leader>fQ",  function() Revert_all_buffers("q!") end,                 desc = "Auto Revert",    mode = "n" },
    { "<leader>ff",  require('yazi').yazi,                                    desc = "Find File",      mode = "n" },
    { "<leader>fo",  group = "Open" }, -- group
    { "<leader>foc", require('utils.change_directory').change_to_clipboard_file,    desc = "Clipboard",      mode = "n" },
    { "<leader>foC", require('utils.change_directory').change_to_clipboard_file_git_root,    desc = "Clipboard",      mode = "n" },
    { "<leader>fon", require('utils/misc').open_notes,                        desc = "Clipboard",      mode = "n" },
    { "<leader>foz", "<cmd>lua vim.fn.jobstart({ 'zeditor.sh' }, { noremap = true, silent = false })<CR>",                        desc = "Zed Editor",     mode = "n" },
    { "<leader>fs",  function() vim.cmd [[w]] end,                            desc = "Save",           mode = "n" },
    { "<leader>fe",  function() vim.cmd [[e!]] end,                           desc = "Revert",         mode = "n" },
    { "<leader>fE",  function() Revert_all_buffers() end,                     desc = "Revert",         mode = "n" },
    { "<leader>fg",  require('utils.change_directory').change_to_file_dir,                    desc = "Go to File Dir", mode = "n" },
    { "<leader>fG",  require('utils.change_directory').change_to_git_root,                    desc = "Go to Project Dir", mode = "n" },
    { "<leader>fr",  function() require('telescope.builtin').oldfiles() end,  desc = "Recent" },
    { "<leader>ft",  function() require('telescope.builtin').filetypes() end, desc = "File Types" },
    { "<leader>fy",  require('utils/misc').copy_path,                         desc = "Copy Path" },
    { "<leader>fY",  require('utils/misc').copy_base_path,                    desc = "Copy Path" },
    { "<leader>fp",  require('utils/misc').open_config,                       desc = "Edit Config" },
    {
      "<leader>fj",
      function()
        vim.cmd("e " .. "~/Notes/slipbox/" .. "j_" .. os.date("%Y-%m-%d") .. ".md")
      end,
      desc = "Edit Config"
    }

  }
})



-- Notes
wk.add({
  {
    { "<leader>n",  group = "Notes" }, -- group
    { "<leader>nc", require("utils/markdown_babel").send_code,               desc = "Execute a markdown cell and include output" },
    { "<leader>nb", require('utils/telescope_markdown-links').open_backlink, desc = "Insert Notes Link" },
    {
      "<leader>nL",
      function()
        require('utils/telescope_markdown-links').insert_notes_link({ dir = vim.fn.getcwd()
        })
      end,
      desc = "Insert Notes Link"
    },
    -- { "<leader>nL",  function() Insert_notes_link_alacritty_fzf() end,              desc = "Insert Notes Link" },
    { "<leader>nl",  function() Insert_chalsedony_link_egui() end,              desc = "Insert Notes Link" },
    -- { "<leader>nL", Insert_notes_link,                                desc = "Insert Notes Link" },
    { "<leader>ns",  function() Create_markdown_link(true) end,                     desc = "Create a Subpage Link and Open Buffer" },
    { "<leader>nS",  function() Create_markdown_link() end,                         desc = "Create a Link From text and Open Buffer" },
    { "<leader>nu",  Format_url_markdown,                                           desc = "Format a URL as a Markdown Link" },
    { "<leader>nv",  function() Generate_navigation_tree() end,                     desc = "Generate Navigation Tree" },
    { "<leader>nr",  require('render-markdown').toggle,                             desc = "Render Markdown Toggle" },
    { "<leader>nip", function() Paste_png_image() end,                              desc = "Paste Image from Clipboard" },
    { "<leader>nic", require('utils/markdown_notes').make_cite_page,                desc = "Make a Citation Page" },
    -- { "<leader>na",  Attach_file,                                      desc = "Prompt User to attach file under ./assets" },
    { "<leader>na",  function() require("utils/markdown_attach").attach_file() end, desc = "Prompt User to attach file under ./assets" },
    { "<leader>nz",  Search_notes_fzf,                                              desc = "Search Notes using Embeddings" },
    { "<leader>nj",  group = "Notes" }, -- group
  }
})


-- Toggle
wk.add({
  { "<leader>t",  group = "toggle" },
  { "<leader>to", require('utils/telescope_stream_ollama_model').choose_model, desc = "Ollama Model" },
  { "<leader>ts", group = "Snippets Mode" },
  {
    "<leader>tg",
    function()
      -- nvim-focus/focus.nvim
      vim.cmd([[FocusToggle]])
    end,
    desc = "Testing"
  },
  -- The old approach of using a symlink
  { "<leader>tsL", require('config/snippy_symlink_toggle').toggle,      desc = "Toggle Auto LaTeX Snippets", mode = "n" },
  { "<leader>tsa", function() My_snippy_state.toggles.contextual() end, desc = "Contextual LaTeX" },
  { "<leader>tsl", function() My_snippy_state.toggles.latex() end,      desc = "LaTeX Mode" }
})



wk.add({
  { "<leader>t", group = "Toggle" }, -- group
  {
    { "<leader>ta", function() require('utils/toggle_autosave').toggle() end,   desc = "Autosave",              mode = "n" },
    { "<leader>td", function() require('config.themes').toggle() end,           desc = "Toggle Dark",           mode = "n" },
    { "<leader>tn", require('notify').dismiss,                                  desc = "Dismiss notifications", mode = "n" },
    { "<leader>tx", "<cmd>split<CR><cmd>terminal tx<CR>",                       desc = "Dismiss notifications", mode = "n" },
    { "<leader>tf", require('telescope.builtin').filetypes,                     desc = "Filetype",              mode = "n" },
    { "<leader>th", require('utils/misc').conceal_toggle,                       desc = "Conceal",               mode = "n" },
  },
})

-- TODO wrap with ipairs for automatic Alt-# bindings.
wk.add({
  { "<leader>tm", group = "Toggle+Mode" }, -- group
  {
    { "<leader>tmo", function() ChangeMode(ModalLayer.Organize) end, desc = "Organize", mode = "n" },
    { "<leader>tmr", "<cmd>lua ChangeMode(ModalLayer.Resize)<CR>",   desc = "Resize",   mode = "n" },
    { "<M-2>",       "<cmd>lua ChangeMode(ModalLayer.Resize)<CR>",   desc = "Buffer",   mode = "n" },
    { "<leader>tmm", "<cmd>lua ChangeMode(ModalLayer.Move)<CR>",     desc = "Move",     mode = "n" },
    { "<M-4>",       "<cmd>lua ChangeMode(ModalLayer.Move)<CR>",     desc = "Buffer",   mode = "n" },
    { "<leader>tmb", "<cmd>lua ChangeMode(ModalLayer.Buffer)<CR>",   desc = "Buffer",   mode = "n" },
    { "<M-3>",       "<cmd>lua ChangeMode(ModalLayer.Buffer)<CR>",   desc = "Buffer",   mode = "n" },
    { "<leader>tmt", "<cmd>lua ChangeMode(ModalLayer.Tabs)<CR>",     desc = "Buffer",   mode = "n" },
    { "<M-1>",       "<cmd>lua ChangeMode(ModalLayer.Tabs)<CR>",     desc = "Buffer",   mode = "n" },
    { "<leader>tmg", "<cmd>lua ChangeMode(ModalLayer.Git)<CR>",      desc = "Git",      mode = "n" },
    { "<leader>tms", "<cmd>lua ChangeMode(ModalLayer.Search)<CR>",   desc = "Search",   mode = "n" },
    { "<leader>tmn", "<cmd>lua ChangeMode(ModalLayer.None)<CR>",     desc = "None",     mode = "n" },
    { "<leader>tmv", "<cmd>lua ChangeMode(ModalLayer.Split)<CR>",    desc = "Split",    mode = "n" },
  }
})

wk.add({
  { "<leader>ts", group = "Toggle+Snippets" }, -- group
  {
  }
})

wk.add({
  { "<leader>j",  group = "Jupyter Notebook",                                       icon = { cat = "extension", name = "ipynb" } }, -- group
  { "<leader>jj", require('utils/notebooks').jupytext_set_formats,                  desc = "Jupytext Pair" },
  { "<leader>jp", require('utils/notebooks').quarto_preview,                        desc = "Jupytext Pair" },
  { "<leader>js", require('utils/notebooks').jupytext_sync,                         desc = "Jupytext Sync" },
  { "<leader>jS", function() require('utils/notebooks').jupytext_sync(true) end,    desc = "Jupytext Sync" },
  { "<leader>jw", require('utils/notebooks').jupytext_watch_sync,                   desc = "Watch Jupytext Sync" },
  { "<leader>jo", require('utils/notebooks').open_in_vscode,                        desc = "Open in VSCode" },
  { "<leader>jm", require('utils/notebooks').jupytext_render_markdown_with_quarto,  desc = "Export to Markdown (Quarto)" },
  { "<leader>jM", require('utils/notebooks').jupytext_render_markdown_with_jupyter, desc = "Export to Markdown (Jupyter)" },
  { "<leader>jv", group = "View" }, -- subgroup for view commands
  {
    { "<leader>jva", require('utils/notebooks').open_all_formats, desc = "All" },
    { "<leader>jvm", function() vim.cmd [[:vsplit %:r.md]] end, desc = "Markdown" },
    { "<leader>jvn", function() vim.cmd [[:vsplit %:r.Rmd]] end, desc = "Rmd" },
    { "<leader>jvp", function() vim.cmd [[:vsplit %:r.py]] end, desc = "Python" },
    { "<leader>jvr", function() vim.cmd [[:vsplit %:r.r]] end, desc = "Python" },
    { "<leader>jvj", function() vim.cmd [[:vsplit %:r.jl]] end, desc = "Julia" },
    { "<leader>jvs", function() vim.cmd [[:vsplit %:r.rs]] end, desc = "Rust" },
    { "<leader>jvi", function() vim.cmd [[:vsplit %:r.ipynb]] end, desc = "⚠ ipynb" },
  }
})

-- Folding
wk.add({
  { "<leader>z", group = "Folding" }, -- group
  {
    { "<leader>zz", require('utils.outshine_folding').toggle,                      desc = "Toggle Outshine Mode",        mode = "n" },
    { "<leader>ze", require('utils.outshine_folding').enable,                      desc = "Enable Outshine",             mode = "n" },
    { "<leader>zd", require('utils.outshine_folding').disable,                     desc = "Disable Outshine (Use LSP)",  mode = "n" },
    { "<leader>za", require('utils.outshine_folding').add_markers,                 desc = "Add Fold Marker (Level 1)",   mode = { "n", "v" } },
    { "<leader>zA", require('utils.outshine_folding').add_markers_with_end,        desc = "Add Fold Markers with End",   mode = { "n", "v" } },
    { "<leader>zp", require('utils.outshine_folding').add_markers_prompt,          desc = "Add Fold Marker (Prompt)",    mode = { "n", "v" } },
    { "<leader>z1", function() require('utils.outshine_folding').add_markers(1) end, desc = "Add Level 1 Marker",        mode = { "n", "v" } },
    { "<leader>z2", function() require('utils.outshine_folding').add_markers(2) end, desc = "Add Level 2 Marker",        mode = { "n", "v" } },
    { "<leader>z3", function() require('utils.outshine_folding').add_markers(3) end, desc = "Add Level 3 Marker",        mode = { "n", "v" } },
    { "<leader>z4", function() require('utils.outshine_folding').add_markers(4) end, desc = "Add Level 4 Marker",        mode = { "n", "v" } },
    { "<leader>z5", function() require('utils.outshine_folding').add_markers(5) end, desc = "Add Level 5 Marker",        mode = { "n", "v" } },
    { "<leader>z6", function() require('utils.outshine_folding').add_markers(6) end, desc = "Add Level 6 Marker",        mode = { "n", "v" } },
    { "<leader>z7", function() require('utils.outshine_folding').add_markers(7) end, desc = "Add Level 7 Marker",        mode = { "n", "v" } },
    { "<leader>z8", function() require('utils.outshine_folding').add_markers(8) end, desc = "Add Level 8 Marker",        mode = { "n", "v" } },
  }
})

-- Go
wk.add({
  { "<leader>g",  group = "Go" }, -- group
  { "<leader>gv", "<cmd>Navbuddy<CR>", desc = "Navbuddy" },
})


-- v Vim
wk.add({

  { "<leader>h", group = "Help" }, -- group
  {
    { "<leader>ht", require('telescope.builtin').colorscheme, desc = "Theme" },
    { "<leader>hp", "<cmd>Telescope lazy<CR>",                desc = "Packages" },
    { "<leader>hu", "<cmd>Lazy update<CR>",                   desc = "Lazy Update" },
  }
})


-- v view / Vim
wk.add({
  { "<leader>v", group = "Vim" }, -- group
  {
    { "<leader>vs", "<cmd>so %<cr>", desc = "Find File", mode = "n" },
    -- { "<leader>vm",  group = "Mode" },
    -- { "<leader>vml", function() vim.cmd [[source /tmp/file.lua]] end, desc = "LaTeX Mode" }
  }
})

wk.add({
  { "<leader>v", group = "Preview" }, -- group
  {

    {
      "<leader>vA",
      function()
        require('utils/markdown_toggle_autocmd_vscode').toggle()
        require('notify')("Auto VSCode Markdown Preview")
      end,
      desc = "Auto VSCode Markdown Preview",
      mode = "n"
    },
    { "<leader>vv", "<cmd>MarkdownPreview<CR>",                                                                                                               desc = "Markdown Preview",          mode = "n" },
    { "<leader>vc", "<cmd>!codium --disable-gpu % 1>/dev/null 2>&1 & disown<CR>",                                                                             desc = "Markdown Preview (VSCode)", mode = "n" },
    { "<leader>vt", "<cmd>lua vim.fn.jobstart({ 'qutebrowser', 'http://preview.vidar/?path='.. vim.fn.expand('%') }, { noremap = true, silent = true })<CR>", desc = "Markdown Preview (Tatum)",  mode = "n" }
  }
})

-- Insert
wk.add({
  { "<leader>i",  group = "insert" },
  { "<leader>im", function() Send_visual_to_ai_tools_math() end,                  desc = "Convert Visual Selection to Katex", mode = "v" },
  { "<leader>iu", require('telescope.builtin').symbols,                           desc = "Symbols",                           mode = "n" },
  -- todo this is worth doing with a vmap
  -- look at ollama codestral
  { "<leader>it", "<cmd>! /home/ryan/.local/scripts/python/text_to_latex.py<CR>", desc = "Text to Latex",                     mode = "v" },
})

wk.add({
  { "<leader>" }
})


--------------------------------------------------------------------------------
-- Footnotes -------------------------------------------------------------------
--------------------------------------------------------------------------------
--[[
[fn_1]: [Auto-reloading a file in VIM as soon as it changes on disk - Super User](https://superuser.com/questions/181377/auto-reloading-a-file-in-vim-as-soon-as-it-changes-on-disk)

-]]
