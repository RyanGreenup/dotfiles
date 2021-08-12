

""" ##################################################
"####### My Vim Settings ##########################
"##################################################
"
"
"
""" Generic Settings
"##############################
"####### Generic Settings #####
"##############################

" set autochdir " this might bake plugins but it's just way too fucking confusing otherwise, I keep forgetting to hit `SPC f c d`
set nocompatible
set mouse=a " this is brillian for touch screen ; requires `apt install vim-gtk`
filetype plugin on
syntax on
set number "Absolute Number
"set autochdir "This will conflict with some things
"                " So instead I'm just going to be minful to open
"                vim in ranger in the desired working directory
nnoremap <silent><Leader>fcd :cd %:p:h<CR>
nnoremap <silent><Leader>fcd :lcd %:p:h<CR>
nmap <Leader>fp :e ~/.vimrc <CR>
"noremap <silent> <leader>fy :let @+=expand("%:p")<CR>
noremap <silent> <leader>fy :! echo "%" \| xargs realpath \| xclip -selection clipboard <CR><CR><CR>

set relativenumber
imap jj <Esc> " What I'm Used to
imap fd <Esc> " What Spacemacs Uses
imap jk <Esc> " What Doom Uses

" If latent files get annoying consider doing:
" set undodir/.vim/undodir
" 	Or whatever directory
set ignorecase
set smartcase " if you search for something purely lowercase, it will do a case insensitive search
set autoread  "Automatically re-read files
set encoding=utf-8

""""" Keyboard Remaps
"""""" Leader Key
"This is probably for the best because matches spacemacs/Doom
"let mapleader="\<Space>"
map <Space> <Leader>
"""""" Remaps
nmap <Leader><Space> :Commands<CR>
nmap <C-x><C-k> :bd<CR>
nmap <Leader>rr "
nmap <leader>wd :q<CR>
nmap <leader>w <C-w>
nmap <leader>fd :! rm "%"
nmap <leader>ss :BLines<CR>
nmap <leader>bb :Buffers<CR>
map <leader>bp :bprev<CR>
nnoremap <silent><Leader>ff :Files<CR>
" Change Directory to file location
nnoremap <silent><Leader>fcd :cd %:p:h<CR>

""""""" Clipboard
" Write file leader-clip-reymap
"
"
nnoremap <Leader>fs h:w<CR> 
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P


""""" Switch to Markdown and LaTeX Quickly
nnoremap <Leader>t :setlocal filetype=tex<CR>
nnoremap <Leader>m :set syntax=markdown<CR> 



"""" Plugins
"############################## 
"###### Plugins ############### 
"############################## 

""""" Vim-Plug

" Set up if not already installed [jgvpwtai]
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.config/nvim/plugged')

" Make sure you use single quotes

""""" Vim Themes
Plug 'morhetz/gruvbox' 
Plug 'dracula/vim'

""""" Programming
" Corresct spacing
au BufNewFile,BufRead *.py,*.js,*.jl,*.rs,*.go,*.css
    \ setlocal tabstop=4
    \ softtabstop=4
    \ shiftwidth=4
    \ textwidth=79
    \ expandtab
    \ autoindent
    \ fileformat=unix

au BufNewFile,BufRead *.py setlocal foldmethod=indent
autocmd FileType python nnoremap <buffer> <F9> :update<bar>!python %<CR>
autocmd FileType R nnoremap <buffer> <F9> :update<bar>!Rscript %<CR>
autocmd FileType r nnoremap <buffer> <F9> :update<bar>!Rscript %<CR>



""""" LSP
" The LSP Magic
Plug 'neovim/nvim-lspconfig'
" Tie it in with Autocomplete
Plug 'nvim-lua/completion-nvim'
" fzf is better
Plug 'ojroques/nvim-lspfuzzy'

" Make it work in Gnvim (only needed for gnvim)
Plug 'vhakulinen/gnvim-lsp'
Plug 'prabirshrestha/vim-lsp'

""""" LaTeX
Plug 'junegunn/fzf.vim'
Plug 'lervag/vimtex'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
""""" Markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
imap lv :MakrdownPreview<CR>
Plug 'plasticboy/vim-markdown'
""""" General
Plug 'metakirby5/codi.vim'
""""" Powerline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_powerline_fonts = 1
" Make sure to install the fonts with
"      pip install --user git+git://github.com/powerline/powerline
"      pip3 install --user git+git://github.com/powerline/powerline
let g:airline_theme='violet'
"let g:airline_statusline_ontop=1
let g:airline#extensions#tabline#enabled = 1
 
""""" Easy Motion

Plug 'easymotion/vim-easymotion'

" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)



""""" End Plugins
" Initialize plugin system
call plug#end()

"""" LaTeX
""""" PlasticBoy
" This enables syntax highlighting  for Math environments
let g:vim_markdown_math = 1
    "Highlighting is necessary for UltiSnips
    "set syntax=latex sucks because headings don't get highlighted
" Autosave before BuffJump
let g:vim_markdown_autowrite = 1
" Conceal Bold etc.

""""" VimTeX
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_levelmarker = "*"
let g:vimtex_compiler_latexmk = {
      \ 'options' : [
      \   '-shell-escape',
      \   '-silent',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \ ],
      \ 'build_dir' : 'livepreview',
      \}
"disable errors but for good cause
" to view quickfix warning buffer use `<leader>le` 
" they disappear with =fks= mode
"let g:vimtex_quickfix_enabled=0


"""" Programming
""""" Completion-Nvim (Completion Framework for LSP)
" https://github.com/nvim-lua/completion-nvim 

" On all Buffers
autocmd BufEnter * lua require'completion'.on_attach()
let g:completion_enable_snippet = 'UltiSnips'
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

""""" LSP
lua require('lspfuzzy').setup{}
lua require'lspconfig'.rust_analyzer.setup{}
lua require'lspconfig'.clangd.setup{}
lua require'lspconfig'.cssls.setup{}
lua require'lspconfig'.dockerls.setup{}
lua require'lspconfig'.gopls.setup{}
lua require'lspconfig'.bashls.setup{}
" yay -S vscode-html-languageserver; ln -s /usr/bin/vscode-html-languageserver /usr/bin/vscode-html-language-server
lua require'lspconfig'.html.setup{}
" lua require'lspconfig'.java_language_server.setup{}
lua require'lspconfig'.texlab.setup{}
lua require'lspconfig'.pyright.setup{}
lua require'lspconfig'.julials.setup{}
lua require'lspconfig'.r_language_server.setup{}
" yay -S sql-language-server
" TODO This seems to not work, investigate :checkhealth
" lua require'lspconfig'.sqlls.setup{}
" pacman -S stylelint
lua require'lspconfig'.stylelint_lsp.setup{}
" Yay -S vala-language server
lua require'lspconfig'.vala_ls.setup{}
" yay -S vim-language-server
lua require'lspconfig'.vimls.setup{}
" yay -S zls
lua require'lspconfig'.zls.setup{}
lua require'lspconfig'.texlab.setup{}

" Probably won't need these
" lua require'lspconfig'.dartls.setup{}
" lua require'lspconfig'.angularls.setup{}

""""" Tree Sitter


""" Modeline Folding
set modeline
set modelineexpr  "This does all the magic folding
   " This is always enabled in OG vim, in nvim it must be physically enabled
     " Vim will giv a warning about not recognising this command, which is
     " fine because it shouldn't and it notifies us that we are using vim and
     " not nvim. Google "vim modeline vulnerability 2019" for more info 


" Found this [here](https://vi.stackexchange.com/a/3820)

" vim:fdm=expr:fdl=0
" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
"
" Comments MUST be on the first column or this will break, that's the issue

" [jgvpwtai]: https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation  
