local wk = require('which-key')

vim.cmd [[ set timeoutlen=10 ]]
local n = require('notify')

local theme = "ivy" -- Allowed: dropdown, ivy, ...
function telescope_command(s, s2)
  local command = "<cmd>" .. s .. " theme=" .. theme .. "<cr>"
  return { command, s2 }
end

wk.register({
  ["<leader>"] = {
    -- ["<leader>"] = { "<cmd>Telescope<CR>", "Telescope" },
    -- ["<leader>"] = { "<cmd>Telescope find_files theme=ivy<cr>", "Find File" },
    -- ["'"] = { "<cmd>Telescope resume<CR>", "Telescope Resume" },
    ["<leader>"] = telescope_command("Telescope find_files", "Find File"),
    ["'"] = telescope_command("Telescope resume", "Telescope Resume"),

    -- a = {"<cmd>Tabularize /\\s\\+<CR>", "Align"},
    a = { "<cmd>Tabularize /|<CR>", "Align" },

    b = {
      name = "+buffers",
      b = { "<cmd>Telescope buffers<CR>", "Buffers" },
      d = { "<cmd>bd<CR>", "Delete" },
      n = { "<cmd>bn<CR>", "Buffer Previous" },
      p = { "<cmd>bp<CR>", "Buffer Next" },
    },
    c = {
      name = "+create",
      f = { "<cmd>!touch <c-r><c-p><cr><cr>", "Create File" },
    },
    d = {
      name = "+debug",
      t = { "<cmd>lua require('dapui').toggle()<CR>", "Toggle Debug UI" },
      b = { "<cmd>lua require('dap').toggle_breakpoint()<CR>", "Toggle Breakpoint" },
      s = { "<cmd>lua require'dap'.continue()<CR>", "Start or Continue" },
      o = { "<cmd>lua require'dap'.step_over()<CR>", "Step over" },
      i = { "<cmd>lua require'dap'.step_in()<CR>", "Step in" },
      r = { "<cmd>lua require'dap'.repl.open()<CR>", "REPL" },
      ["?"] = { "<cmd>lua dap_usage()<CR>", "Key Bindings" },


    },
    f = {
      name = "+file",
      f = telescope_command("Telescope file_browser", "Find File"),
      z = telescope_command("Telescope find_files", "Fzf File"),
      t = { "<cmd>Telescope filetypes theme=dropdown<cr>", "Find File" },
      r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      n = { "<cmd>enew<cr>", "New File" },
      o = {
        name = "+open",
        c = { "<cmd>lua Open_file_in_clipboard()<cr>", "Open Clipboard" },
      },
      p = { "<cmd>e ~/.config/nvim/init.lua<CR>:cd %:p:h<CR>:cd lua<CR>", "Edit Config" },
      g = { "<cmd>:cd %:p:h<cr>", "Go to file (cd)" },
      y = { '<cmd>:let @+=expand("%:p")<cr>', "Copy File Path" },
      Y = { '<cmd>:let @+=expand("%")<cr>"%:p")<cr>', "Copy File Path" },
      s = { '<cmd>:w!<cr>', "Save" },
      e = { '<cmd>:e!<cr>', "Revert" },

    },
    g = {
      name = "+go",
      d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "LSP: Definition" },
      D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "LSP: Definition" },
      i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "LSP: Implementation" },
      r = { "<cmd>lua vim.lsp.buf.references()<CR>", "LSP: References" },
      v = { "<cmd>Navbuddy<CR>", "Navbuddy" },
      n = {
        name = "+notes",
        d = { "<cmd>:cd ~/Notes/dokuwiki/config/dokuwiki/data/pages/<CR><cmd>Telescope find_files<CR>", "Dokuwiki" }
      }
    },
    h = {
      name = "help",
      h = { "<cmd>Telescope help_tags<CR>", "Help" },
      r = { "<cmd>:PackerCompile<CR><cmd>source $MYVIMRC<cr>", "source $MYVIMRC" },
      t = { "<cmd>Telescope colorscheme theme=dropdown<cr>", "Choose Theme" },
      u = { "<cmd>:PackerSync<CR>", "Packer Sync" },
      p = { "<cmd>Telescope packer theme=dropdown<CR>", "Help Packages" },

    },
    n = {
      name = "+notes",
      l = { ":lua Insert_notes_link()<CR>", "Insert a link to a note using rofi" },
      s = { ":CreateMarkdownLink<CR>", "Create a Subpage Link and Open Buffer" },
      u = { ":lua Format_url_markdown()<CR>", "Format a URL as a Markdown Link" },
      v = { ":lua Generate_navigation_tree()<CR>", "Generate Navigation Tree" },
      r = { "<cmd>RenderMarkdownToggle<CR>", "Render Markdown Toggle" },
      p = { "<cmd>lua Paste_png_image()<CR>", "Paste Image from Clipboard" },
      f = {
        name = "+format",
        t = { "<Esc>vap<cmd>'<,'>!pandoc -t commonmark_x<CR>", "Format Table" }
      }
    },
    o = {
      name = "+open / org",
      s = { "<cmd>cd ~/.config/nvim/snippets/<CR><cmd>Telescope find_files<CR>", "Snippets Directory" },
      n = { "<cmd>e ~/Notes/slipbox/home.md<CR><cmd>cd ~/Notes/slipbox/ <CR>", "Notes" },
      -- May sometimes need --disable-gpu
      v = { "<cmd>!/usr/bin/distrobox-enter  -n r -- /bin/sh -l -c  \"/usr/share/codium/codium --disable-gpu --unity-launch % 1>/dev/null 2>&1\" 1>/dev/null 2>&1 & disown<CR>", "VSCode" },
      h = { ":lua Change_dayplanner_line(-30)<CR>", "Decrease Dayplanner Time" },
      j = { ":lua Open_journals()<CR>", "Open Journal Pages" },
    },
    s = {
      name = "+search",
      -- s = { "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Swoop" },
      s = telescope_command("Telescope current_buffer_fuzzy_find", "Swoop"),
      d = { "<cmd>Telescope lsp_document_symbols<CR>", "LSP Document 🔣" },
      j = { "<cmd>Telescope jumplist theme=ivy<CR>", "Jumplist" },
      D = { "<cmd>Telescope lsp_workspace<CR>", "LSP workspace" },
      i = { "<cmd>Telescope ultisnips<CR>", "Ultisnips" },
      e = { "<cmd>Telescope quickfix<CR>", "Errors" },
      r = { "<cmd>Telescope lsp_references<CR>", "LSP References" },
      m = telescope_command("Telescope marks", "Marks"),

    },
    r = {
      name = "Iron",
      c = { "<cmd>:IronSend<CR>", "line" },
      ["?"] = { "<cmd>lua iron_keybindings()<CR>", "Key Bindings" },
    },
    l = {
      name = "LSP",
      t = { "<cmd>lua Toggle_inlay_hints()<CR>", "Toggle Inlay Hints" },
      g = {
        name = "+go",
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
        D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Definition" },
        i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
        r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
      },
      q = { "<cmd>LspStop<CR>", "Stop LSP" },
      k = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover (S-k)" },
      h = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
      w = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", "Workspace Folder" },
      W = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", "Remove Workspace Folder" },
      x = { "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", "List folders" },
      T = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type Definition" },
      r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
      a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
      f = { "<cmd>lua vim.lsp.buf.format { async = true }<CR>", "Format (Async)" }, -- NOTE unsupported on OBSD
      F = { "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", "Format" },
    },
    t = {
      name = "Toggle",
      a = { ":lua ToggleAutoSave()<CR>", "Autosave" },
      n = { "<cmd>lua require('notify').dismiss()<CR>", "Dismiss notifications" },
      f = { "<cmd>Telescope filetypes<CR>", "Filetype" },
      x = { "<cmd>Telescope tmux sessions theme=ivy<CR>", "Tmux Sessions" },
      h = { "<cmd>lua Conceal_toggle()<CR>", "Conceal" },
      m = {
        name = "mode+",
        o = { "<cmd>lua ChangeMode(ModalLayer.Organize)<CR>", "Organize" },
        r = { "<cmd>lua ChangeMode(ModalLayer.Resize)<CR>", "Resize" },
        m = { "<cmd>lua ChangeMode(ModalLayer.Move)<CR>", "Move" },
        b = { "<cmd>lua ChangeMode(ModalLayer.Buffer)<CR>", "Buffer" },
        g = { "<cmd>lua ChangeMode(ModalLayer.Git)<CR>", "Git" },
        s = { "<cmd>lua ChangeMode(ModalLayer.Search)<CR>", "Search" },
        n = { "<cmd>lua ChangeMode(ModalLayer.None)<CR>", "None" },
        v = { "<cmd>lua ChangeMode(ModalLayer.Split)<CR>", "Split" },
      },
      s = {
        name = "Snippets",
        {
          l = { "<cmd> lua Snippy_Toggle_Auto()<CR>", "Toggle Auto LaTeX Snippets" }
        }
      }

    },
    i = {
      name = "insert",
      u = { "<cmd>Telescope symbols<CR>", "Symbols" },
    },
    v = {
      name = "Preview",
      -- using iamcco/markdown-preview.nvim
      v = { "<cmd>MarkdownPreview<CR>", "Markdown Preview" },
      -- using VSCode
      c = { "<cmd>!/usr/bin/distrobox-enter  -n r -- /bin/sh -l -c  \"/usr/share/codium/codium --disable-gpu --unity-launch % 1>/dev/null 2>&1\" 1>/dev/null 2>&1 & disown<CR>", "Markdown Preview (VSCode)" },
    },
    w = {
      name = "+window",
      -- Splits
      v = { "<cmd>:vsplit<CR>", "vsplit" },
      s = { "<cmd>:split<CR>", "hsplit" },
      h = { "<C-w>h", "Move Left" },
      j = { "<C-w>j", "Move Down" },
      k = { "<C-w>k", "Move Up" },
      l = { "<C-w>l", "Move Right" },
      q = { "<cmd>q<CR>", "quit" },
      t = {
        name = "+tab",
        e = { "<cmd>tabedit<CR>", "Edit" },
        x = { "<cmd>tabclose<CR>", "Close" },
        p = { "<cmd>tabprevious<CR>", "Previous" },
        n = { "<cmd>tabnext<CR>", "Next" },
        o = { "<cmd>tabedit<CR>", "Open Tab" },
        m = { "<cmd>lua Move_window_to_tab()<CR>", "Move" },


      },
      T = { "<C-w> t", "New Tab" },
      o = { "<C-w>|<C-w>_", "maximize" },
      O = { "<cmd>only<CR>", "Max (:only)" },
      m = { "<C-w>s<C-w>v<C-w>w<C-w>s", "Many splits" },
      ["_"] = { "<C-w>_", "Flatten" },
      ["|"] = { "<C-w>|", "Width" },
      ["="] = { "<C-w>=", "Resize" },
    },
    q = { ":qa!<CR>", "Quit all!" },
    ["<Left>"] = { "<cmd>vertical resize +15<CR>", "Resize ⬅" },
    ["<Right>"] = { "<cmd>vertical resize -15<CR>", "Resize ➡" },
    ["<Up>"] = { "<cmd>         resize +15<CR>", "Resize ⬇" },
    ["<Down>"] = { "<cmd>         resize -15<CR>", "Resize ⬆" },
    ["/"] = { "<cmd>Telescope live_grep<CR>", "Resize" },
  },
})


-- TODO configure this through which key instead
--      Disable in iron and enable in which key
local function iron_keybindings()
  local message = [[
  ~/.config/nvim/lua/plugins/iron.lua
  ______________________________________

    send_motion....SPC s c
    visual_send....SPC s c
    send_file......SPC s f
    send_line......SPC s l
    send_mark......SPC s m
    mark_motion....SPC m c
    mark_visual....SPC m c
    remove_mark....SPC m d
    cr.............SPC s Ret
    interrupt......SPC s SPC
    exit...........SPC s q
    clear..........SPC c l

  ______________________________________

  These are set separetly, hence this overlay
  ]]
  local n = require('notify')
  n(message)
end

function dap_usage()
  local message = [[
  Debugging
  ___________
    First set a break point with <F9>, then
    open  up  the  UI  with  <F4> and start
    debugging with <F5>.

    Use <F10> and  <F11> to go over and in
    functions and <S-F11> if needed to get
    out.

  _________________________________________
    Toggle Breakpoint...<F9>......SPC d b t
    Toggle UI...........<F4>......SPC d t
    ---------------------------------------
    Start Debugging.....<F5>......SPC d s c
    Step Over...........<F10>.....SPC d s v
    Step Into...........<F11>.....SPC d s c
    Step Out............<S-F11>...SPC d s c
  _________________________________________

  If the dap isn't installed run:
    `:DBInstall <Tab>`

  ]]
  local n = require('notify')
  n(message)
end

wk.register()


wk.register({
  d = {
    name = "Debug",
    n = { "<cmd>lua require('dap').step_into()<CR>", "Step In" },
    o = { "<cmd>lua require('dap').step_over()<CR>", "Step Over" },
    O = { "<cmd>lua require('dap').step_out()<CR>", "Step Out" },
    d = { "<cmd>lua require('dap').continue()<CR>", "Continue" },
    ["<Space>"] = { "<cmd>lua require('dap').toggle_breakpoint()<CR>", "Continue" },
    s = {
      name = "Step",
      c = { "<cmd>lua require('dap').continue()<CR>", "Continue" },
      v = { "<cmd>lua require('dap').step_over()<CR>", "Step Over" },
      i = { "<cmd>lua require('dap').step_into()<CR>", "Step Into" },
      o = { "<cmd>lua require('dap').step_out()<CR>", "Step Out" },
    },
    h = {
      name = "Hover",
      h = { "<cmd>lua require('dap.ui.variables').hover()<CR>", "Hover" },
      v = { "<cmd>lua require('dap.ui.variables').visual_hover()<CR>", "Visual Hover" },
    },
    u = {
      name = "UI",
      h = { "<cmd>lua require('dap.ui.widgets').hover()<CR>", "Hover" },
      f = { "local widgets=require('dap.ui.widgets');widgets.centered_float(widgets.scopes)<CR>", "Float" },
    },
    r = {
      name = "Repl",
      o = { "<cmd>lua require('dap').repl.open()<CR>", "Open" },
      l = { "<cmd>lua require('dap').repl.run_last()<CR>", "Run Last" },
    },
    b = {
      name = "Breakpoints",
      c = {
        "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        "Breakpoint Condition",
      },
      m = {
        "<cmd>lua require('dap').set_breakpoint({ nil, nil, vim.fn.input('Log point message: ') })<CR>",
        "Log Point Message",
      },
      t = { "<cmd>lua require('dap').toggle_breakpoint()<CR>", "Create" },
    },
    c = { "<cmd>lua require('dap').scopes()<CR>", "Scopes" },
    i = { "<cmd>lua require('dap').toggle()<CR>", "Toggle" },
  },
}, { prefix = "<leader>" })


-- VISUAL mode mappings
-- s, x, v modes are handled the same way by which_key
wk.register({
  -- ...
  ["<C-g>"] = {
    c = { ":<C-u>'<,'>GpChatNew<cr>", "Visual Chat New" },
    p = { ":<C-u>'<,'>GpChatPaste<cr>", "Visual Chat Paste" },
    t = { ":<C-u>'<,'>GpChatToggle<cr>", "Visual Toggle Chat" },

    ["<C-x>"] = { ":<C-u>'<,'>GpChatNew split<cr>", "Visual Chat New split" },
    ["<C-v>"] = { ":<C-u>'<,'>GpChatNew vsplit<cr>", "Visual Chat New vsplit" },
    ["<C-t>"] = { ":<C-u>'<,'>GpChatNew tabnew<cr>", "Visual Chat New tabnew" },

    r = { ":<C-u>'<,'>GpRewrite<cr>", "Visual Rewrite" },
    a = { ":<C-u>'<,'>GpAppend<cr>", "Visual Append (after)" },
    b = { ":<C-u>'<,'>GpPrepend<cr>", "Visual Prepend (before)" },
    i = { ":<C-u>'<,'>GpImplement<cr>", "Implement selection" },

    g = {
      name = "generate into new ..",
      p = { ":<C-u>'<,'>GpPopup<cr>", "Visual Popup" },
      e = { ":<C-u>'<,'>GpEnew<cr>", "Visual GpEnew" },
      n = { ":<C-u>'<,'>GpNew<cr>", "Visual GpNew" },
      v = { ":<C-u>'<,'>GpVnew<cr>", "Visual GpVnew" },
      t = { ":<C-u>'<,'>GpTabnew<cr>", "Visual GpTabnew" },
    },

    n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
    s = { "<cmd>GpStop<cr>", "GpStop" },
    x = { ":<C-u>'<,'>GpContext<cr>", "Visual GpContext" },

    w = {
      name = "Whisper",
      w = { ":<C-u>'<,'>GpWhisper<cr>", "Whisper" },
      r = { ":<C-u>'<,'>GpWhisperRewrite<cr>", "Whisper Rewrite" },
      a = { ":<C-u>'<,'>GpWhisperAppend<cr>", "Whisper Append (after)" },
      b = { ":<C-u>'<,'>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
      p = { ":<C-u>'<,'>GpWhisperPopup<cr>", "Whisper Popup" },
      e = { ":<C-u>'<,'>GpWhisperEnew<cr>", "Whisper Enew" },
      n = { ":<C-u>'<,'>GpWhisperNew<cr>", "Whisper New" },
      v = { ":<C-u>'<,'>GpWhisperVnew<cr>", "Whisper Vnew" },
      t = { ":<C-u>'<,'>GpWhisperTabnew<cr>", "Whisper Tabnew" },
    },
  },
  -- ...
}, {
  mode = "v", -- VISUAL mode
  prefix = "",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
})

-- NORMAL mode mappings
require("which-key").register({
  -- ...
  ["<C-g>"] = {
    c = { "<cmd>GpChatNew<cr>", "New Chat" },
    t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
    f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },

    ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
    ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
    ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },

    r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
    a = { "<cmd>GpAppend<cr>", "Append (after)" },
    b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

    g = {
      name = "generate into new ..",
      p = { "<cmd>GpPopup<cr>", "Popup" },
      e = { "<cmd>GpEnew<cr>", "GpEnew" },
      n = { "<cmd>GpNew<cr>", "GpNew" },
      v = { "<cmd>GpVnew<cr>", "GpVnew" },
      t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
    },

    n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
    s = { "<cmd>GpStop<cr>", "GpStop" },
    x = { "<cmd>GpContext<cr>", "Toggle GpContext" },

    w = {
      name = "Whisper",
      w = { "<cmd>GpWhisper<cr>", "Whisper" },
      r = { "<cmd>GpWhisperRewrite<cr>", "Whisper Inline Rewrite" },
      a = { "<cmd>GpWhisperAppend<cr>", "Whisper Append (after)" },
      b = { "<cmd>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
      p = { "<cmd>GpWhisperPopup<cr>", "Whisper Popup" },
      e = { "<cmd>GpWhisperEnew<cr>", "Whisper Enew" },
      n = { "<cmd>GpWhisperNew<cr>", "Whisper New" },
      v = { "<cmd>GpWhisperVnew<cr>", "Whisper Vnew" },
      t = { "<cmd>GpWhisperTabnew<cr>", "Whisper Tabnew" },
    },
  },
  -- ...
}, {
  mode = "n", -- NORMAL mode
  prefix = "",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
})

-- INSERT mode mappings
require("which-key").register({
  -- ...
  ["<C-g>"] = {
    c = { "<cmd>GpChatNew<cr>", "New Chat" },
    t = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
    f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },

    ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
    ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
    ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },

    r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
    a = { "<cmd>GpAppend<cr>", "Append (after)" },
    b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

    g = {
      name = "generate into new ..",
      p = { "<cmd>GpPopup<cr>", "Popup" },
      e = { "<cmd>GpEnew<cr>", "GpEnew" },
      n = { "<cmd>GpNew<cr>", "GpNew" },
      v = { "<cmd>GpVnew<cr>", "GpVnew" },
      t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
    },

    x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
    s = { "<cmd>GpStop<cr>", "GpStop" },
    n = { "<cmd>GpNextAgent<cr>", "Next Agent" },

    w = {
      name = "Whisper",
      w = { "<cmd>GpWhisper<cr>", "Whisper" },
      r = { "<cmd>GpWhisperRewrite<cr>", "Whisper Inline Rewrite" },
      a = { "<cmd>GpWhisperAppend<cr>", "Whisper Append (after)" },
      b = { "<cmd>GpWhisperPrepend<cr>", "Whisper Prepend (before)" },
      p = { "<cmd>GpWhisperPopup<cr>", "Whisper Popup" },
      e = { "<cmd>GpWhisperEnew<cr>", "Whisper Enew" },
      n = { "<cmd>GpWhisperNew<cr>", "Whisper New" },
      v = { "<cmd>GpWhisperVnew<cr>", "Whisper Vnew" },
      t = { "<cmd>GpWhisperTabnew<cr>", "Whisper Tabnew" },
    },
  },
  -- ...
}, {
  mode = "i", -- INSERT mode
  prefix = "",
  buffer = nil,
  silent = true,
  noremap = true,
  nowait = true,
})



local conceal_level = 0
local ever_fired = false
function Conceal_toggle()
  local new_level = 0
  if ever_fired == false then
    new_level = 0
    ever_fired = true
  else
    new_level = (conceal_level + 1) % 3
  end
  local message = "Conceal level: " .. conceal_level .. " --> " .. new_level
  local cmd = "set conceallevel=" .. new_level
  require('notify')(message)
  vim.cmd(cmd)
  conceal_level = new_level
end

function Open_file_in_clipboard()
  local path = vim.fn.getreg("+")
  -- check if the file exists
  local file = io.open(path, "r")
  if file == nil then
    print("File does not exist: " .. path)
    return
  end
  file:close()
  vim.cmd(":e " .. path)
end


function Toggle_inlay_hints()
  if vim.fn.has "nvim-0.10" == 1 then
    local ok = pcall(vim.lsp.inlay_hint.enable, vim.lsp.inlay_hint.is_enabled())
    if ok then
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    else
      vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
    end
  end
end
