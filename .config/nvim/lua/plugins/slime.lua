vim.g.slime_target = "zellij"

vim.cmd([[
let g:slime_default_config = {"session_id": "current", "relative_pane": "right"}

" I needed this to fix ipython (ptpython loses a \n though)
let g:slime_bracketed_paste = 1

" Don't ask for settings, trigger the prompt with :SlimeConfig
" let g:slime_dont_ask_default = 1

" Preserver the cursor position
let g:slime_preserve_curpos = 0

" Don't move the cursor
let g:slime_preserve_curpos = 0



" Change the default bindings
" let g:slime_no_mappings = 1


" These are commented out, consider the ./iron.lua bindings first
" Default is C-c C-c
" C-CR doesn't work in zellij?
" xmap <M-e> <Plug>SlimeRegionSend
" nmap <M-e> <Plug>SlimeParagraphSend
" nmap <c-c>v     <Plug>SlimeConfig
]])
