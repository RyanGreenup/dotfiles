local wk = require('which-key')

vim.cmd [[ set timeoutlen=10 ]]
local n = require('notify')


wk.register({
  ["<leader>"] = {
    ["<leader>"] = { "<cmd>Telescope<CR>", "Telescope" },
    ["'"] = { "<cmd>Telescope resume<CR>", "Telescope Resume" },

    b = {
      name = "+buffers",
      b = { "<cmd>Telescope buffers<CR>", "Buffers" },

      p = { "<cmd>bp<CR>", "Buffer Previous" },
      n = { "<cmd>bn<CR>", "Buffer Next" },
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
      f = { "<cmd>Telescope file_browser theme=ivy<cr>", "Find File" },
      z = { "<cmd>Telescope find_files theme=dropdown<cr>", "Find File" },
      t = { "<cmd>Telescope filetypes theme=dropdown<cr>", "Find File" },
      r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      n = { "<cmd>enew<cr>", "New File" },
      p = { "<cmd>e ~/.config/nvim/init.lua<CR>:cd %:p:h<CR>:cd lua<CR>", "Edit Config" },
      g = { "<cmd>:cd %:p:h<cr>", "Go to file (cd)" },
      y = { '<cmd>:let @+=expand("%:p")<cr>', "Copy File Path" },
      Y = { '<cmd>:let @+=expand("%")<cr>"%:p")<cr>', "Copy File Path" },

    },
    g = {
      name = "+go",
      d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "LSP: Definition" },
      D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "LSP: Definition" },
      i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "LSP: Implementation" },
      r = { "<cmd>lua vim.lsp.buf.references()<CR>", "LSP: References" },
    },
    h = {
      name = "help",
      h = { "<cmd>Telescope help_tags<CR>", "Help" },
      r = { "<cmd>:PackerCompile<CR><cmd>source $MYVIMRC<cr>", "source $MYVIMRC" },
      t = { "<cmd>Telescope colorscheme theme=dropdown<cr>", "Choose Theme" },
      u = { "<cmd>:PackerSync<CR>", "Packer Sync" },
      p = { "<cmd>Telescope packer theme=dropdown<CR>", "Help Packages" },

    },
    o = {
      name = "+open",
      s = { "<cmd>cd .config/nvim/LuaSnip/<CR><cmd>Telescope find_files<CR>", "Snippets Directory" },
    },
    s = {
      name = "+search",
      s = { "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Swoop" },
      -- d = { "<cmd>Telescope lsp_document_symbols<CR>",      "LSP document" },
      d = { "<cmd>Vista finder<CR>", "LSP document" },
      D = { "<cmd>Vista finder!<CR>", "LSP workspace" },
      i = { "<cmd>Telescope ultisnips<CR>", "Ultisnips" },
      e = { "<cmd>Telescope quickfix<CR>", "Errors" },

    },
    r = {
      name = "Iron",
      c = { "<cmd>:IronSend<CR>", "line" },
      ["?"] = { "<cmd>lua iron_keybindings()<CR>", "Key Bindings" },
    },
    l = {
      name = "LSP",
      g = {
        name = "+go",
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
        D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Definition" },
        i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementation" },
        r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
      },
      q = { "<cmd>LspStop<CR>", "Stop LSP"},
      k = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover (S-k)" },
      h = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
      w = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", "Workspace Folder" },
      W = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", "Remove Workspace Folder" },
      x = { "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", "List folders" },
      t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type Definition" },
      r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
      a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
    f = { "<cmd>lua vim.lsp.buf.format { async = true }<CR>", "Format (Async)" }, -- NOTE unsupported on OBSD
    F = { "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", "Format" },
    },
    t = {
      name = "Toggle",
      A = { "<cmd>autocmd TextChanged,TextChangedI <buffer> silent write<CR>:lua require('notify')('Enabled save autocmd')<CR>", "Autosave" },
      n = { "<cmd>lua require('notify').dismiss()<CR>", "Dismiss notifications" },
      x = { "<cmd>Telescope tmux sessions theme=ivy<CR>", "Tmux Sessions" },

    },
    i = {
      name = "insert",
      s = { "<cmd>Telescope luasnip<CR>", "Snippet" },
      u = { "<cmd>Telescope symbols<CR>", "Symbols" },
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
      d = { "<cmd>:q<CR>", "quit" },
      t = {
        name = "+tab",
        e = { "<cmd>tabedit<CR>", "Edit" },
        x = { "<cmd>tabclose<CR>", "Close" },
        p = { "<cmd>tabprevious<CR>", "Previous" },
        n = { "<cmd>tabnext<CR>", "Next" },
        o = { "<cmd>tabsplit<CR>", "Open Tab" },


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


function iron_keybindings()
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




wk.register({
    d = {
        name = "Debug",
        n = { "<cmd>lua require('dap').step_into()<CR>", "Step In"   },
        o = { "<cmd>lua require('dap').step_over()<CR>", "Step Over" },
        O = { "<cmd>lua require('dap').step_out()<CR>",  "Step Out"  },
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
