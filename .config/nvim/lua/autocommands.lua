local cmd = vim.cmd -- execute Vim commands

-- Create Groups --------------------------------------------------------------
local python_group = vim.api.nvim_create_augroup("Python", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("Markdown", { clear = true })

-- Create Functions
function file_autocmd_command(pattern, group, command, desc)
  vim.api.nvim_create_autocmd(
    { "BufNewFile", "BufRead", "FileType" },
    {
      pattern = pattern,
      group = group,
      command = command,
      desc = desc,
    })
end

function file_autocmd_function(event, pattern, group, callback_function)
  vim.api.nvim_create_autocmd(event,
    {
      pattern = pattern,
      group = group,
      callback = callback_function
    })
end

-- Create Factories -----------------------------------------------------------
function file_autocmd_command_factory(pattern, group)
  return function(command, desc)
    file_autocmd_command(pattern, group, command, desc)
  end
end

file_autocmd_function_factory = function(pattern, group)
  return function(event, callback_function)
    file_autocmd_function(event, pattern, group, callback_function)
  end
end




-- Python Autocommands --------------------------------------------------------
local py_pattern = "*.py"
-- Create Helpers
file_autocmd_command_py = file_autocmd_command_factory('*.py', python_group)
file_autocmd_function_py = file_autocmd_function_factory('*.py', python_group)
-- Autocmd Commands
file_autocmd_command_py('set cindent', 'Allow Indenting Comments and Code in Python')
vim.api.nvim_create_autocmd(
  { "BufNewFile" },
  {
    pattern = py_pattern,
    group = python_group,
    command = '0r ~/Templates/python_script.py',
    desc = "Load Python Template",
  })
-- Autocmd Callback Functions
-- Python Autocommands --------------------------------------------------------
-- Create Helpers
file_autocmd_command_md = file_autocmd_command_factory('*.md', markdown_group)
file_autocmd_function_md = file_autocmd_function_factory('*.md', markdown_group)
-- Autocmd Commands
file_autocmd_command_md('set foldexpr=nvim_treesitter#foldexpr()', 'Set Fold Expression to Treesitter')
file_autocmd_command_md('lua print("Hello")', 'Print Hello in Lua')
file_autocmd_command_md('set foldmethod=expr', 'Set Fold Method to Expression')
file_autocmd_command_py('set cindent', 'Allow Indenting Comments and Code in code blocks')
-- [^6158294]
file_autocmd_command_md(
  ':nmap <C-CR> "<Esc>:e <cfile><CR>" <CR>',
  'Create a New Markdown File from bracketed link')
-- Autocmd Callback Functions

-- Ansible Autocommands -------------------------------------------------------
-- NOTE This breaks the mnemonic above, because there's multiple exts
local exts = { "*yaml.ansible", "*ansible.yaml", "*playbook.yaml" }
local commands = {
  "set filetype=yaml",
  "LspStart ansiblels",
  [[ nmap <F2> :w<CR>:!ansible-playbook "%"<CR> ]],
  [[ nmap <F3> :!neofetch ]],
  "set foldmethod=indent",
}

for _, ext in ipairs(exts) do
  for _, c in ipairs(commands) do
    local s = "autocmd BufNewFile,BufRead " .. ext .. " " .. c
    vim.cmd(s)
  end
end



-- Keymaps --------------------------------------------------------------------
local run_file = {
  { '*.py',    '!python "%"' },
  { '*.md',    '!pandoc "%" -o "%:r.html"' },
  { '*.go',    '!go run "%"' },
  { '*.c',     '!gcc -o "%:r" "%" && ./"%:r"' },
  { '*.cpp',   '!g++ -o "%:r" "%" && ./"%:r"' },
  { '*.rs',    '!cargo run' },
  { '*.sh',    '!bash "%"' },
  { '*.lua',   ':source "%"' },
  { '*.vim',   ':source "%"' },
  { '*.tex',   '!pdflatex -shell-escape "%"' },
  { '*.julia', ':julia "%"' },
  { '*.r',     '!Rscript "%"' },
  { '*.zig',   '!zig run "%"' },
}

for _, value in ipairs(run_file) do
  local pattern = value[1]
  local command = value[2]
  command = "map <buffer> <F2> <Esc>:w<CR>:exec '" .. command .. "'<CR>"
  local imap_command = "i" .. command
  local nmap_command = "n" .. command

  for _, c in ipairs({ imap_command, nmap_command }) do
    vim.api.nvim_create_autocmd(
      { "BufNewFile", "BufRead", "FileType" },
      {
        pattern = pattern,
        command = c,
      })
  end
end

-- [[ References
-- [^6158294]: https://stackoverflow.com/questions/6158294/how-to-create-and-open-for-editing-a-nonexistent-file-whose-path-is-under-the-cu
-- ]]


-- TODO  Clean up this file to have a better abstraction for FileType, BufNewFile, BufRead etc.
-- vim.cmd [[
--
--   autocmd FileType markdown set foldexpr=nvim_treesitter#foldexpr()
--   autocmd FileType markdown set foldmethod=expr
-- ]]

vim.api.nvim_create_autocmd(
  { "FileType" },
  {
    pattern = "markdown",
    command = "set foldexpr=nvim_treesitter#foldexpr()",
    desc = "Set Fold Expression to Treesitter",

  })

vim.api.nvim_create_autocmd(
  { "FileType" },
  {
    pattern = "markdown",
    command = "set foldmethod=expr",
    desc = "Set Fold Method to Expression",

  })

vim.api.nvim_create_autocmd(
  { "FileType" },
  {
    pattern = "markdown",
    command = "set cindent",
    desc = "Set Fold Method to Expression",

  })

vim.api.nvim_create_autocmd(
  { "FileType" },
  {
    pattern = "python",
    command = "set cindent",
    desc = "Set Fold Expression to Treesitter",

  })
