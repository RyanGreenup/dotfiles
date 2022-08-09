local wk = require('which-key')

vim.cmd [[ set timeoutlen=10 ]]

wk.register({
  o = {
    name = "Org", -- optional group name
    a = { "Agenda" },
    A = { "Archive" },
    c = { "Capture" },
    t = { "Set Tag" },
    r = { "Refile" },
    o = { "Open at Point" },
    k = { "Cancel Edit Source" },
    w = { "Save Edit Source" },
    K = { "Move Subtree Up" },
    J = { "Move Subtree Down" },
    e = { "Export" },
    i = {
      name = "Insert",
      d = { "Deadline" },
      h = { "Heading" },
      T = { "Mark TODO" },
      t = { "Toggle Below" },
      s = { "Schedule" }
    },
    x = {
      name = "Clock",
      o = { "Clock Out" },
      i = { "Clock In" },
      q = { "Cancel Clock" },
      j = { "Jump to Clock" },
      e = { "Set Effort" },
    }
  },
}, { prefix = "<leader>" })



wk.register({
  ["<leader>"] = {
    ["<leader>"] = { "<cmd>Telescope<CR>", "Telescope" },

    b = {
      name = "+buffers",
      p = { "<cmd>bp<CR>", "Buffer Previous" },
      n = { "<cmd>bn<CR>", "Buffer Next" },
    },
    f = {
      name = "+file",
      f = { "<cmd>Telescope find_files theme=dropdown<cr>", "Find File" },
      r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      n = { "<cmd>enew<cr>", "New File" },
      p = { "<cmd>e ~/.config/nvim/init.lua<CR>:cd %:p:h<CR>:cd lua<CR>", "Edit Config" },
    },
    h = {
      name = "help",
      r = { "<cmd>source $MYVIMRC<cr>", "source $MYVIMRC" },
      t = { "<cmd>Telescope colorscheme theme=dropdown<cr>", "Choose Theme" },
      u = { "<cmd>:PackerSync<CR>", "Packer Sync" },
      p = { "<cmd>Telescope packer theme=dropdown<CR>", "Help Packages" },

    },
    s = {
      name = "+search",
      s = { "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Swoop" },
      -- d = { "<cmd>Telescope lsp_document_symbols<CR>",      "LSP document" },
      d = { "<cmd>Vista finder<CR>", "LSP document" },
      D = { "<cmd>Vista finder!<CR>", "LSP workspace" },


    },
    o = {
      name = "Org", -- optional group name
      a = { "Agenda" },
      A = { "Archive" },
      c = { "Capture" },
      t = { "Set Tag" },
      r = { "Refile" },
      o = { "Open at Point" },
      k = { "Cancel Edit Source" },
      w = { "Save Edit Source" },
      K = { "Move Subtree Up" },
      J = { "Move Subtree Down" },
      e = { "Export" },
      i = {
        name = "Insert",
        d = { "Deadline" },
        h = { "Heading" },
        T = { "Mark TODO" },
        t = { "Toggle Below" },
        s = { "Schedule" }
      },
      x = {
        name = "Clock",
        o = { "Clock Out" },
        i = { "Clock In" },
        q = { "Cancel Clock" },
        j = { "Jump to Clock" },
        e = { "Set Effort" },
      }
    },
    t = {
      name = "Toggle",
      a = { "<cmd>ASToggle<CR>:lua require('notify')('Toggled Autosave')<CR>", "Autosave" },
      n = { "<cmd>lua require('notify').dismiss()<CR>", "Dismiss notifications" },
      g = { "<cmd>GoldenRatioToggle<CR>", "Golden Ratio" }
    },
    i = {
      name = "insert",
      u = { "<cmd>Telescope symbols<CR>", "Symbols" },
    },
    w = {
      name = "Window",
      -- Splits
      v = { "<cmd>:vsplit<CR>", "vsplit" },
      s = { "<cmd>:split<CR>", "hsplit" },
      h = { "<C-w>h", "Move Left" },
      j = { "<C-w>j", "Move Down" },
      k = { "<C-w>k", "Move Up" },
      l = { "<C-w>l", "Move Right" },
      d = { "<cmd>q<CR>", "quit" },
      q = { "<cmd>:q<CR>", "quit" },
      ["="] = { "<C-w>=", "Resize" },
    },
    q = { ":qa!", "Quit all!" },
    ["<Left>"] = { "<cmd>vertical resize +15<CR>", "Resize ⬅" },
    ["<Right>"] = { "<cmd>vertical resize -15<CR>", "Resize ➡" },
    ["<Up>"] = { "<cmd>         resize +15<CR>", "Resize ⬇" },
    ["<Down>"] = { "<cmd>         resize -15<CR>", "Resize ⬆" },
    ["/"] = { "<cmd>Telescope live_grep<CR>", "Resize" },
  },
})
