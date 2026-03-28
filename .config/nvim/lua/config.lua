--- Declarative user configuration for this Neovim setup.
--- Centralises preferences that multiple modules may read.
--- settings.lua applies vim options from here; plugin configs read their sections directly.
return {
  ui = {
    number = true,
    relativenumber = false,
    showmatch = true,
    colorcolumn = '80',
    splitright = true,
    splitbelow = true,
    linebreak = true,
    termguicolors = true,
    yank_highlight_timeout = 700,
    gui_font = 'FiraCode Nerd Font:h14',
  },
  editing = {
    mouse = 'a',
    clipboard = 'unnamedplus',
    swapfile = false,
    autoread = true,
    ignorecase = true,
    smartcase = true,
    completeopt = 'menuone,noselect',
  },
  indentation = {
    width = 4,
    expandtab = true,
    smartindent = true,
  },
  folding = {
    method = 'expr',
    expr = 'v:lua.vim.treesitter.foldexpr()',
    level = 99,
    levelstart = 99,
  },
  performance = {
    hidden = true,
    history = 100,
    lazyredraw = false,
    synmaxcol = 240,
  },
  behavior = {
    trim_whitespace = true,
  },
  themes = {
    dark = 'catppuccin-macchiato',
    light = 'catppuccin-latte',
  },
  markdown = {
    startup_folded = 'showeverything',
    render_on_open = false,
    fold_ellipsis = '…',
    fold_show_line_count = true,
  },
  vimtex = {
    viewer = 'zathura',
  },
  slime = {
    target = 'tmux',
  },
  iron = {
    repl_open_cmd = 'belowright 15 split',
    python_command = { 'ipython' },
  },
}
