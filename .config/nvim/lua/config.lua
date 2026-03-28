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
    conceallevel = 0,
    concealcursor = 'nc',
    filetypes = { 'markdown', 'mdx', 'mdoc', 'rmd', 'qmd', 'quarto' },
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
  minuet = {
    toggle = '<leader>ai',
    accept = '<A-y>',
    dismiss = '<A-n>',
    next = '<A-o>',
    prev = '<A-i>',
    debounce = 50, -- ms after cursor settles before auto-requesting
    -- Provider: 'cerebras', 'cerebras_llama', 'cerebras_reasoning', or 'openai'
    --   cerebras:           qwen-3-235b, best coding quality ($0.60/$1.20/M), env CEREBRAS_API_KEY
    --   cerebras_llama:     llama3.1-8b, cheapest ($0.10/M), env CEREBRAS_API_KEY
    --   cerebras_reasoning: gpt-oss-120b, non-streaming only ($0.35/$0.75/M)
    --   openai:             gpt-4.1-mini, key at ~/.local/keys/openai.key
    provider = 'cerebras',
    debug = true, -- log request lifecycle to :messages
    cost_display = '<leader>ac', -- show session token usage and cost
    -- Per-million-token pricing (USD). Update when switching providers.
    cost_per_million_input = 0.60,
    cost_per_million_output = 1.20,
  },
}
