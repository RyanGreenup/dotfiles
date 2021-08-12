# Neovim Config

## Language Server

| | |
| --- |  --- |
| Note | Currently it seems that: <br><code>lua require'lspconfig'.java_language_server.setup{}</code> </br> breaks the LSP module|



### Dependencies (Arch)

```
# List Packages ................................................................
packages=(
          "vscode-html-language-server"     # HTML
          "java-language-server"            # Java
          "vim-language-server"             # VimScript
          "vala-language-server"            # Vala
          "haskell-language-server"         # Bash
          "bash-language-server"            # Bash
          "pyright"                         # Python
          "python-language-server"          # Python
          "lua-language-server"             # Lua
          "russt-analyzer"                  # Rust
          "gopls"                           # Go

)

    # Fix Vinary Location ......................................................
    ln -s /usr/bin/vscode-html-languageserver /usr/bin/vscode-html-language-server

# Install the Packages .........................................................
n=${#packages[@]}

for ((i=0; i<${n}; i++ )); do
	yay -S "${packages[i]}"
done
```

### Minimal Config for LSP

```vim
set number "Absolute Number
nnoremap <silent><Leader>fcd :lcd %:p:h<CR>

imap jj <Esc> " What I'm Used to
imap fd <Esc> " What Spacemacs Uses
imap jk <Esc> " What Doom Uses

set ignorecase
set smartcase " if you search for something purely lowercase, it will do a case insensitive search
set autoread  "Automatically re-read files
set encoding=utf-8

""""" Keyboard Remaps
nmap <Leader><Space> :Commands<CR>
nmap <C-x><C-k> :bd<CR>
nmap <Leader>rr "
nmap <leader>wd :q<CR>
nmap <leader>w <C-w>
nmap <leader>fd :! rm "%"
nmap <leader>ss :BLines<CR>
nmap <leader>bb :Buffers<CR>


"""" Plugins
"############################## 
"###### Plugins ############### 
"############################## 

""""" Vim-Plug

" Set up if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

""""" Programming
""""" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'


""""" End Plugins
" Initialize plugin system
call plug#end()

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



```

### Testing

```bash
cd "$(mktemp -d)"
cargo init my_lsp_test # should be snake
nvim "$(find ./ -name main.rs)"
```

Auto complete should be offered, if not inspect `:LspInfo`
