local cmd = vim.cmd -- execute Vim commands

-- Create Groups --------------------------------------------------------------
local python_group = vim.api.nvim_create_augroup("Python", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("Markdown", { clear = true })

-- Create Functions
function file_autocmd_command(pattern, group, command, desc)
  vim.api.nvim_create_autocmd(
    { "BufNewFile", "BufRead" },
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
-- Create Helpers
file_autocmd_command_py = file_autocmd_command_factory('*.py', python_group)
file_autocmd_function_py = file_autocmd_function_factory('*.py', python_group)
-- Autocmd Commands
file_autocmd_command_py('set cindent', 'Allow Indenting Comments and Code in Python')
file_autocmd_command_py('0r ~/Templates/python_script.py', "Load Python Template")
-- Autocmd Callback Functions
-- Python Autocommands --------------------------------------------------------
-- Create Helpers
file_autocmd_command_md = file_autocmd_command_factory('*.md', markdown_group)
file_autocmd_function_md = file_autocmd_function_factory('*.md', markdown_group)
-- Autocmd Commands
file_autocmd_command_md('set foldmethod=expr', 'Set Fold Method to Expression')
file_autocmd_command_md('set foldexpr=nvim_treesitter#foldexpr()', 'Set Fold Expression to Treesitter')
file_autocmd_command_md(
  'nmap <C-CR> "zviby :cd %:p:h<cr> :!touch <C-R>z<CR> :e <C-R>"<CR>',
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
      { "BufNewFile", "BufRead" },
      {
        pattern = pattern,
        command = c,
      })
  end
end
