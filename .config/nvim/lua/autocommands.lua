local cmd = vim.cmd -- execute Vim commands

-- Skeletons, see `:h skeleton`
-- Only when running :e
cmd [[
  autocmd BufNewFile  *.py	0r /home/ryan/Templates/python_script.py
]]

-- Dynamic Keymaps
-----------------------------------------------------------
-- Autocommands
-----------------------------------------------------------

-- https://stackoverflow.com/questions/18948491/running-python-code-in-vim
vim.cmd [[
  autocmd FileType python  map <buffer>  <F2> :w<CR>:exec      '!python3' shellescape(@%, 1)<CR>
  autocmd FileType python imap <buffer> <F2> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

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


]]

-- Configure Ansible
vim.cmd [[
  autocmd BufNewFile,BufRead *.yaml.ansible set filetype=yaml
  autocmd BufNewFile,BufRead *.yaml.ansible LspStart ansiblels
]]
