-- Create Groups --------------------------------------------------------------
local python_group = vim.api.nvim_create_augroup("Python", { clear = true })
local markdown_group = vim.api.nvim_create_augroup("Markdown", { clear = true })


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


function create_autocommand(events, attributes)
  vim.api.nvim_create_autocmd(events, attributes)
end

local autocmds = {
  {
    events = { "BufNewFile" },
    attrs = {
      {
        pattern = "python",
        group = python_group,
        command = '0r ~/Templates/python_script.py',
        desc = "Load Python Template",
      }
    }
  },
  {
    events = { "FileType" },
    attrs = {
      {
        pattern = "markdown",
        group = markdown_group,
        command = "set foldexpr=nvim_treesitter#foldexpr()",
        desc = "Set Fold Expression to Treesitter",
      },
      {
        pattern = "markdown",
        group = markdown_group,
        command = "set foldmethod=expr",
        desc = "Set Fold Method to Expression",
      },
      {
        pattern = "markdown",
        group = markdown_group,
        command = "set nocindent",
        desc = "Set No C Indent -- This causes auto indent on new lines",
      },

      {
        pattern = "python",
        command = "set cindent",
        desc = "Set Fold Expression to Treesitter",
      }
    }
  },
}

for _, autocmd in pairs(autocmds) do
  for _, attr in pairs(autocmd.attrs) do
    create_autocommand(autocmd.events, attr)
  end
end

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


-- [[ References
-- [^6158294]: https://stackoverflow.com/questions/6158294/how-to-create-and-open-for-editing-a-nonexistent-file-whose-path-is-under-the-cu
-- ]]
