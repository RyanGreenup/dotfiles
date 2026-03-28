--- Declarative user configuration for this Neovim setup.
--- Centralises preferences that multiple modules may read.
return {
  ui = {
    colorcolumn = '80',
    relativenumber = false,
    splitright = true,
    splitbelow = true,
    yank_highlight_timeout = 700,
    gui_font = 'FiraCode Nerd Font:h14',
  },
  indentation = {
    width = 4,
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
