local cmd = vim.cmd -- execute Vim commands


-- [fn_1]
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Skeletons, see `:h skeleton`
-- Only when running :e
cmd [[
  autocmd BufNewFile  *.py	0r /home/ryan/Templates/python_script.py
]]

function file_autocmd(cmd, patterns)
  autocmd('Filetype', {
    pattern = patterns,
    command = cmd
  })
end


-- Create a function to create an autocommand
local autocmd = vim.api.nvim_create_autocmd

-- Create a function to create a filetype autocommand
function file_autocmd(cmd, patterns)
  autocmd('Filetype', {
    pattern = patterns,
    command = cmd
  })
end

function autocmds(filetype, cmds)
  for _, c in ipairs(cmds) do
    file_autocmd(c, { filetype })
  end
end

-- Set Markdown Autocommands

file_autocmd("markdown", {
  [[ nmap <C-CR> "zviby :cd %:p:h<cr> :!touch <C-R>z<CR> :e <C-R>"<CR> ]],
  [[ nmap <buffer> <F2> :w<CR>:exec '!pandoc' shellescape(@%, 1)<CR> ]],
  [[ imap <buffer> <F2> <esc>:w<CR>:exec '!pandoc' shellescape(@%, 1)<CR> ]],
  [[ set foldmethod=expr ]],
  [[ set foldexpr=nvim_treesitter#foldexpr() ]],
})


-- Set Python Autocommands
file_autocmd("markdown", {
  [[ set cindent ]],
  [[ map  <buffer> <F2> :w<CR>:exec      '!python3' shellescape(@%, 1)<CR> ]],
  [[ imap <buffer> <F2> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR> ]],
})


-- Dynamic Keymaps
-----------------------------------------------------------
-- Autocommands
-----------------------------------------------------------

-- https://stackoverflow.com/questions/18948491/running-python-code-in-vim
-- autocmd FileType python  map <buffer>  <F2> :w<CR>:exec      '!python3' shellescape(@%, 1)<CR>
-- autocmd FileType python imap <buffer> <F2> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
vim.cmd [[

  autocmd FileType go     map <buffer>     <F2> :w<CR>:exec      '!go run' shellescape(@%, 1)<CR>
  autocmd FileType go    imap <buffer>     <F2> <esc>:w<CR>:exec '!go run' shellescape(@%, 1)<CR>

  autocmd FileType c      map <buffer>      <F2> :w<CR>:exec      '!tcc -run' shellescape(@%, 1)<CR>
  autocmd FileType c     imap <buffer>      <F2> <esc>:w<CR>:exec '!tcc -run' shellescape(@%, 1)<CR>

  autocmd FileType r      map <buffer>  <F2> :w<CR>:exec      '!Rscript' shellescape(@%, 1)<CR>
  autocmd FileType r     imap <buffer> <F2> <esc>:w<CR>:exec '!Rscript' shellescape(@%, 1)<CR>

  autocmd FileType julia  map <buffer>  <F2> :w<CR>:exec      '!julia' shellescape(@%, 1)<CR>
  autocmd FileType julia imap <buffer>  <F2> <esc>:w<CR>:exec '!julia' shellescape(@%, 1)<CR>

  autocmd FileType zig map <buffer>  <F2> :w<CR>:exec      '!zig run' shellescape(@%, 1)<CR>
  autocmd FileType zig imap <buffer>  <F2> <esc>:w<CR>:exec '!zig run' shellescape(@%, 1)<CR>

  autocmd FileType zig map <buffer>  <F2> :w<CR>:exec      '!zig run' shellescape(@%, 1)<CR>
  autocmd FileType zig imap <buffer>  <F2> <esc>:w<CR>:exec '!zig run' shellescape(@%, 1)<CR>

  autocmd FileType markdown set foldmethod=expr
  autocmd FileType markdown set foldexpr=nvim_treesitter#foldexpr()

]]

-- Configure Ansible
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



file_autocmd([[
  nmap <C-CR> "zviby :cd %:p:h<cr> :!touch <C-R>z<CR> :e <C-R>"<CR> ]],
  { "markdown" })

--[[

[fn_1]: https://github.com/brainfucksec/neovim-lua/blob/main/nvim/lua/core/autocmds.lua

--]]
