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

"""" Vim-Plug

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
"
""""" General Stuff
"Auto-Save
Plug '907th/vim-auto-save'
" example
let g:nv_search_paths = ['~/Notes/MD/', '~/Dropbox/Notes/MD/notes/', '~/writing', '~/code', 'docs.md' , './notes.md']

" Open in Last Place
Plug 'farmergreg/vim-lastplace'

" Airline Display bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_powerline_fonts = 1
" Make sure to install the fonts with
"      pip install --user git+git://github.com/powerline/powerline
"      pip3 install --user git+git://github.com/powerline/powerline
let g:airline_theme='violet'
"let g:airline_statusline_ontop=1
let g:airline#extensions#tabline#enabled = 1

" Notational Velocity
Plug 'https://github.com/alok/notational-fzf-vim'

"Folding plugin to work like org-mode
"Plug 'msuperdock/vim-foldout'
"   "This get's rid of any writing on the fold,
"      It also breaks all the time,
"      leave it off

"SpeedDating
Plug 'tpope/vim-speeddating'


"Distraction Free Editing
Plug 'junegunn/goyo.vim'

"Thesaurus
Plug 'ron89/thesaurus_query.vim'


"Org Mode
Plug 'jceb/vim-orgmode'
"Universal Text Links
Plug 'vim-scripts/utl.vim'
"Calendar
Plug 'itchyny/calendar.vim'

"Use Ranger as the file explorer
Plug 'iberianpig/ranger-explorer.vim'
Plug 'rbgrouleff/bclose.vim'
" Refer to 
"https://github.com/iberianpig/ranger-explorer.vim
"
nnoremap <silent><Leader>ft :RangerOpenCurrentDir<CR>
nnoremap <silent><Leader>ff :Files<CR>
"

""""" vim-markdown-wiki NOT VimWiki
"Plug 'mmai/vim-markdown-wiki'
" This let's me use the format [](./) but vimwiki
" has more features so I may as well leverage those
" features and just fix the [](./) manually
Plug 'vimwiki/vimwiki'

" Fix the titles
 function! MdwiWriteTitle(word)
   return 'normal!\ a# '.strftime('%c').' - '.escape(a:word, ' \').'\<esc>'
 endfunction


""""" Vim-Emoji
"Plug 'junegunn/vim-emoji'
"Plug 'junegunn/vim-github-dashboard'
Plug 'kyuhi/vim-emoji-complete'

Plug 'yazgoo/unicodemoji'

""""" Smooth Scroll
Plug 'yuttie/comfortable-motion.vim'

""""" EasyMotion
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
""""" Citations (Zotero)
" I'm  not going to implement this just yet,
" Pandoc will lead to failures all the time
Plug 'jalvesaq/zotcite'
Plug 'Shougo/unite.vim'
Plug 'rafaqz/citation.vim'
let g:citation_vim_cache_path='~/.vim/cacheForUniteCite/'
let g:citation_vim_bibtex_file="~/Dropbox/Studies/Papers/references.bib"
let g:citation_vim_mode="bibtex"
let g:citation_vim_outer_prefix="["
let g:citation_vim_inner_prefix="@"
let g:citation_vim_suffix="]"
let g:citation_vim_et_al_limit=2
nmap <leader>u [unite]
nnoremap [unite] <nop>
nnoremap <silent>[unite]c       :<C-u>Unite -buffer-name=citation-start-insert -default-action=append      citation/key<cr>
nnoremap <silent>[unite]co :<C-u>Unite -input=<C-R><C-W> -default-action=start -force-immediately citation/file<cr>
nnoremap <silent><leader>cu :<C-u>Unite -input=<C-R><C-W> -default-action=start -force-immediately citation/url<cr>
nnoremap <silent>[unite]cf :<C-u>Unite -input=<C-R><C-W> -default-action=file -force-immediately citation/file<cr>
nnoremap <silent>[unite]ci :<C-u>Unite -input=<C-R><C-W> -default-action=preview -force-immediately citation/combined<cr>
nnoremap <silent>[unite]cp :<C-u>Unite -default-action=yank citation/your_source_here<cr>
nnoremap <silent>[unite]cs :<C-u>Unite  -default-action=yank  citation/key:<C-R><C-W><cr>
vnoremap <silent>[unite]cs :<C-u>exec "Unite  -default-action=start citation/key:" . escape(@*,' ') <cr>


""""" Nvim-R
Plug 'jalvesaq/Nvim-R'
autocmd BufEnter *.R :imap <A--> <-
autocmd BufEnter *.R :inoremap <C-|> %>%
imap <A-->  <- 
" Vim Can't do <C-S-m> so put up with <C-m>.
  " [[https://stackoverflow.com/questions/1506764/how-to-map-ctrla-and-ctrlshifta-differently]]
autocmd BufEnter *.R :imap <C0m> %>% 

" the rmd pandoc plugin creates a bunch of <leader>l bindings
"  this means that when you want to run a line you have to wait a moment for
"  the next key, to fix this change `timeoutlen` (in ms) and rebind:
"

"   \l          *@:call SendLineToR("stay")<CR>

set timeoutlen=300
" imap <M-CR> *@:call SendLineToR("stay")<CR>


"""""" Codi REPL
Plug 'metakirby5/codi.vim'

"""""" CSV Vim
 Plug 'chrisbra/csv.vim'
"""""" Linting
Plug 'dense-analysis/ale'
autocmd BufEnter *.R :ALEDisable
""""" Python-Mode
Plug 'python-mode/python-mode'
" Tabs are now Spaces Globally
    set shiftwidth=4
    "Plug 'davidhalter/jedi-vim'
    " [stack answer](https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces)

""""" Julia Syntax Highlighting
Plug 'JuliaEditorSupport/julia-vim'
Plug 'davidhalter/jedi-vim'

""""" AutoComplete (NCM2)
" This Has No completion source for R
" It does autosuggest the omni-completion
" but I've switched to NCM2 below simply
" for the R support.
"if has('nvim')
"  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"else
"  Plug 'Shougo/deoplete.nvim'
"  Plug 'roxma/nvim-yarp'
"  Plug 'roxma/vim-hug-neovim-rpc'
"endif
"let g:deoplete#enable_at_startup = 1
"call deoplete#custom#option('omni_patterns', {
"		\ 'r': '[^. *\t]\.\w*',
"		\})
"


"""""" NCM2
Plug 'ncm2/ncm2'

if !has('nvim')
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'Shougo/neco-vim'
Plug 'roxma/nvim-yarp'
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect
" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
"

""""""" Sources
" R
Plug 'gaalcaras/ncm-R'
" Go
Plug 'ncm2/ncm2-go'
" Python
Plug 'ncm2/ncm2-jedi'
" Java
Plug 'ObserverOfTime/ncm2-jc2' 
" CSS
Plug 'ncm2/ncm2-cssomni'
" VimScript
Plug 'ncm2/ncm2-vim'
" UltiSnips Completion Source
Plug 'ncm2/ncm2-ultisnips'

"""""""" General 
" Words in Buffer
Plug 'ncm2/ncm2-bufword'
" Path 
Plug 'ncm2/ncm2-path'

"""""""" Potentially Annoying
" Single Line Clipboard Looks in clipboard history
"Plug 'svermeulen/ncm2-yoink' " This caused an error
" Word Completion Looks up possible words
Plug 'filipekiss/ncm2-look.vim'
" Highlights what caused the match
"Plug 'ncm2/ncm2-match-highlight'
Plug 'fgrsnau/ncm2-otherbuf'

"""""" YouCompleteMe
" I'm dropping this, it's too unstable, I blink and it's broken
" It offers fuck-all for the time investment, I can't spend 
" 3hours debugging this every 1-2 weeks, I just can't use it.
"Plug 'ycm-core/YouCompleteMe'
"
" Make sure you have
" sudo pip3 install pynvim 
" neovim-ruby-host
" npm neovim
" perl
" cpanm



""""" LaTeX Stuff
" 
" 
"VimTeX
Plug 'lervag/vimtex'

"Conceal Tex
Plug   'KeitaNakamura/tex-conceal.vim', {'for': 'tex'} " for VimPlug
autocmd BufEnter *.tex set conceallevel=0
autocmd BufEnter *.md set conceallevel=0
let g:tex_conceal="abdgms"
hi clear Conceal "This removes the stupid highlighting

"""""" Markdown Stuff

" Paste Images
Plug 'ferrine/md-img-paste.vim'
autocmd FileType markdown nmap <silent> <leader>cp :call mdip#MarkdownClipboardImage()<CR>
" there are some defaults for image directory and image name, you can change them
 let g:mdip_imgdir = '../attachments'

"PlasticBoy Plugin
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'


" This enables syntax highlighting  for Math environments
let g:vim_markdown_math = 1
    "Highlighting is necessary for UltiSnips
    "set syntax=latex sucks because headings don't get highlighted
" Autosave before BuffJump
let g:vim_markdown_autowrite = 1
" Conceal Bold etc.

"Markdown Preview
"Requires yarn and nodejs, they're available through apt and pacman
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
imap :MakrdownPreview<CR>
" see if this one let's you follow links
"Plug 'suan/vim-instant-markdown', {'for': 'markdown'}



"R-Markdown Preview (rmd)
"Plug 'vim-pandoc/vim-rmarkdown'
" I installed this because of this issue:
" https://github.com/jalvesaq/Nvim-R/issues/197
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'


""""""" Text Objects
Plug 'kana/vim-textobj-user'
" use if/af to search forward for code block, iF/aF goes back
" Then you could fold it with zif
Plug 'coachshea/vim-textobj-markdown' 
"Use i$/a$ for inline math and ie/ae for environments
Plug 'rbonvall/vim-textobj-latex'

"""""" Sandwhich
" use s for sandwhich a/d/r for add delete replace then just text object
Plug 'machakann/vim-sandwich'



""""" Defaults

Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-master branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'


"""" Themes
Plug 'NLKNguyen/papercolor-theme'
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }

" Initialize plugin system
call plug#end()


""" Editing Workflow
"##############################
"##### Editing ################
"##############################

"""" Convert markdown to Mediawiki
nmap <leader>ew :w !pandoc -f markdown -t mediawiki \| xclip -sel clip

"""""" UltiSnips

" Alt only seems to work in NeoVim, not in Vim,
" I tried using M-j and A-j no dice, just use NeoVim.
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"

let g:UltiSnipsJumpForwardTrigger="<A-l>"
let g:UltiSnipsExpandTrigger="<A-l>"
"let g:UltiSnipsJumpForwardTrigger="<c-f>"
let g:UltiSnipsJumpBackwardTrigger="<A-h>"
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/UltiSnips']

 " If you want :UltiSnipsEdit to split your window.
 let g:UltiSnipsEditSplit="vertical"



     


 """" Right Align Text
function! RightAlignVisual() range
    let lim = [virtcol("'<"), virtcol("'>")]
    let [l, r] = [min(lim), max(lim)]
    exe "'<,'>" 's/\%'.l.'v.*\%<'.(r+1).'v./\=StrPadLeft(submatch(0),r-l+1)'
endfunction
function! StrPadLeft(s, w)
    let s = substitute(a:s, '^\s\+\|\s\+$', '', 'g')
    return repeat(' ', a:w - strwidth(s)) . s
endfunction
"""" Open in Emacs
nmap <C-c>E :! emacsclient --create-frame "%" & disown
nmap <C-c>e :! /usr/bin/env XLIB_SKIP_ARGB_VISUALS=1 emacs "%" & disown

"""" AutoCmd

"Use F2 to Compile markdown
"autocmd BufEnter *.tex :map <f2> :w<cr><leader>ll 
autocmd BufEnter *.md :map <f2> :! prevmd "%" <Enter> <Enter>
"autocmd BufEnter *.md :map <leader>lv  :! firefox --new-window "$(echo "%" \| cut -f 1 -d '.').html" & disown <Enter>
" This causes nvim-r to wait which is frustrating

""""" Boostnote
"autocmd BufEnter *.md :setlocal filetype=markdown
autocmd BufEnter *.md :setlocal filetype=markdown
autocmd BufEnter *.cson :setlocal filetype=markdown 

""""" RMarkdown rmd
"autocmd BufEnter *.Rmd :setlocal filetype=markdown 
:autocmd BufEnter *.Rmd :set nowrap 
:autocmd BufEnter *.Rmd :set nospell

autocmd BufEnter *.t :setlocal filetype=javascript

	" all my snippets are in markdown not md
autocmd BufEnter *.cson :set syntax=markdown 
" Switch between math mode editing and tex
" This is handy to quickly switch snippets but
" generally make sure vim-pandoc-syntax means
" markdown snippets will work as well.
" This could be good for RStudio where we have tikz and aligned integration
" nnoremap <Leader>t :set syntax=tex<CR> 
nnoremap <Leader>t :setlocal filetype=tex<CR>
nnoremap <Leader>m :set syntax=markdown<CR> 
nmap <Leader>m :setlocal filetype=markdown<CR> 
nnoremap <C-x><C-t><C-m> :setlocal filetype=markdown<CR> 
nnoremap <C-x><C-t><C-t> :setlocal filetype=tex<CR> 
nnoremap <C-x><C-t><C-r> :e!<CR>

"nnoremap <Leader>r :set syntax=expand('%:e')<CR> 
"nnoremap <Leader>r :e!<CR>
nmap <Leader>r :e!<CR>
nmap <Leader>fp :e ~/.vimrc <CR>

"Map F3 to XeLaTeX


" F12  Mappings
 " Open TexStudio with F12
autocmd BufEnter *.tex :map <f12> :w<cr>:!texstudio "%" <Enter>
autocmd BufEnter *.md :map <f12> :w<cr>:!typora "%" & disown <Enter>
autocmd BufEnter *.md :map <Space>fo :w<cr>:!marktext "%" & disown <Enter>
autocmd BufEnter *.md :map <Space>foa :w<cr>:!atom "%" & disown <Enter>
"autocmd BufEnter *.md :map <f12> :w<cr>:!marktext "%" & disown <Enter>
"autocmd BufEnter *.Rmd :map <f12> :w<cr>:!marktext "%" & disown <Enter>


"""" Templates
autocmd BufNewFile *.tex 0r  ~/Templates/LaTeX/LaTeX.tex
"autocmd BufNewFile *.tex 0r  ~/Dropbox/profiles/Templates/LaTeX/LaTeX.tex
autocmd BufNewFile *.sh 0r  ~/Dropbox/profiles/bin/hworld.sh
autocmd BufNewFile *.R 0r  ~/Templates/RScriptTemplate.R






"""" LaTeX Settings

""""" My Settings 
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


""""" Castel Dev


"    Plug 'lervag/vimtex'
        let g:tex_flavor='latex'
"        let g:vimtex_view_method='mupdf'
"         let g:vimtex_view_method='evince'
        let g:vimtex_view_method='zathura'
"       let g:vimtex_quickfix_mode=0
    





"""" MarkDown
""""" PlasticBoy Settings
" Don't Hide Code Blocks
let g:vim_markdown_conceal_code_blocks = 0
" Syntax highligt code blocks
let g:vim_markdown_fenced_languages = ['csharp=cs', 'bash=sh', 'R=r', 'elisp=el', 'markdown=md', 'python=py', 'c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'mathematica=wsl']
" Follow Anchors
let g:vim_markdown_follow_anchor = 1
" Syntax Highting
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
" Adjust new item indent
let g:vim_markdown_new_list_item_indent=2
"let g:vim_markdown_new_list_item_indent
if (&ft=='md' || &ft=='markdown')
nnoremap <Leader>it :Tocv<CR>
nmap <leader>m2h "+y"!$HOME/bin/m2hRaw

endif

""""" Syntax Highlighting
"This is now handled by a plugin 'vim-pandoc/vim-pandoc-syntax'
  " Because I'm not using `vim-pandoc` as my Plugin of Choise:

"""""" Old method
"Don't Use this method because it means you get
"no Syntax highlighting for non-TeX stuff in MD
   "Have markdown files highlighted like tex so math() context will work
   "autocmd BufEnter *.md :set syntax=tex
   "autocmd BufEnter *.md :set syntax 


""""" tags
"rg --pcre2 "(?<=\s)#[a-zA-Z-@]+\s" -o --no-filename *.md | fzf
"
" MUST be preceeded and terminated with a space
"
" imap <expr> <C-c><C-y> fzf#vim#complete('Rscript ~/bin/ListTags.R >  /dev/null 2>&1; cat /tmp/00tags.csv')
imap <expr> <C-c><C-y> fzf#vim#complete('node ~/bin/printMarkdownTags/yaml-parse.js $HOME/Notes/MD/notes \| sort -u')
imap <expr> <C-c><C-t> fzf#vim#complete('rg --pcre2 "\s#[a-zA-Z-@]+\s" -o --no-filename $HOME/Notes/MD -t md \| sort -u')
"nnoremap <expr> <Space>fg :Rg expand('<cword>') <CR>
nnoremap <expr> ib<Esc><Space>fg :NV expand('<cword>') <CR>

"Search for line under cursor and remove
"(think like a tag after C-x><C-t>
"     b takes you to the beginning of the previous word
"       won't change word will move from whitespace
nnoremap <Leader>ft  b0"tD:NV<C-r>t<BS><CR>

inoremap <C-c><C-f>  <Esc>b0"tD:NV<C-r>t<BS><CR>


" Include # symbol in <C-r><C-w>
:set iskeyword+=#
" [[https://vi.stackexchange.com/questions/4009/include-symbols-in-cword]]
"map <Space>fg :Rg <C-r><C-w>
nmap <Leader>fg :NV <C-r><C-w> <CR>

""""" Markdown Preview
"""""" iamcco
"Refer to [iamcco/markdown-preview](https://github.com/iamcco/markdown-preview.nvim)

" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0 "Auto only works in chromium, if using firefox maybe turn it off
    " This causes crashes when you have more than one vim window

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1 "only works in chromium"

" set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 1

" set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
"
" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
"let g:mkdp_open_ip = '192.168.0.134'
" You have to set up a static ip by modifying `NetworkManager`
" just open the Advanced Network Settings in Ubuntu
"
"
let g:mkdp_open_ip = ''

" specify browser to open preview page
" default: ''
"let g:mkdp_browser = ''
" chromium is way too slow
let g:mkdp_browser = 'firefox'
"let g:mkdp_browser = '/usr/bin/epiphany-browser'

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {}
    \ }

" use a custom markdown style must be absolute path
"let g:mkdp_markdown_css = '/home/ryan/Dropbox/profiles/Templates/CSS/pandocoffic.css'
"let g:mkdp_markdown_css = '/home/ryan/Dropbox/profiles/Emacs/dotemacs/org-css/Killercup.css'
"
"
let g:mkdp_markdown_css = '/home/ryan/Dropbox/profiles/Templates/CSS/gitOrgWrapped.css'

"let g:mkdp_markdown_css = '/home/ryan/Dropbox/profiles/Templates/CSS/HugoThemes/hugo-theme-basic/static/css/style.css'
"let g:mkdp_markdown_css = '/home/ryan/Dropbox/profiles/Templates/CSS/iamccoGithub.css'
    " This is the default but I must specify it in order to change the
    " Code Block Preview
    " Also the iamcco doesn't work for pandoc but only works for the preview
    " The gitorgwrapped one works for pandoc but not for preview, I don't know
	    " well it works for preview but scales too small on mobile
    " why :shrug:

"let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
"let g:mkdp_highlight_css = '/home/ryan/Dropbox/profiles/Templates/CSS/TomorrowNight_HighlightJS.css'
" I got sick of this
" let g:mkdp_highlight_css = '/home/ryan/Dropbox/profiles/Templates/CSS/TomorrowNight_HighlightJS.css'

" let g:mkdp_highlight_css = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.10/styles/dracula.min.css'

" let g:mkdp_highlight_css = ''

" use a custom port to start server or random for empty
 let g:mkdp_port = '8353'

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'


""""" iamcco Markdown Preview Mappings
"This used KaTeX, which is quicker and probably preferable anyway,
"refer to ~/Notes/Notable/KaTeX_and_MD_Notes.md
"
""""" VimWiki
let g:vimwiki_list = [{'path': '~/Notes/MD/', 'syntax': 'markdown', 'ext': '.md'}, {'path': '/var/www/html/peppermint', 'syntax': 'markdown', 'ext': '.md'}]
"let g:vimwiki_list = [{'path': '~/Notes/MD/',
"                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_global_ext = 0 "only set filetype of of markdown inside wiki folder
" Change the Generated links
"     Refer to [[https://github.com/vimwiki/vimwiki/pull/204]]
" Clean bad links from beginning of line
nmap <leader>wc f[;yi[A(./pa.md)0;di[Vvhp0j
" Clean up underscores inside name
nmap <leader>wu f[vi[:s/\%V_/ /ge0j
nmap <C-x><C-w> <Esc>:VimwikiUISelect<Cr>
""""" Default Maps

"nmap <C-x> <Plug>MarkdownPreview
nmap <Leader>v <Plug>MarkdownPreview
nmap <M-s> <Plug>MarkdownPreviewStop
nmap <C-p> <Plug>MarkdownPreviewToggle
" This is a little bit quicker to load
"command! OpenBrowser :silent ! start chrome "file://%:p"
   " Not disowning leaves it tied to vim
"nmap <Leader>b :silent ! start chrome "file://%:p" 
"This has the massive advantage of allowing links to be followed
" This is way fucking better than iamcco!!
nmap <Leader>b :silent ! vivaldi "file://%:p" & disown <CR> 
nmap <Leader>b :silent ! vivaldi "0.0.0.0:8351/%:t" & disown <CR> 

"This with the code copier single click (includes history!) extension is the
"way to go for sure.
"No script breakes this [read this fix](https://support.mozilla.org/en-US/questions/1157703)

" you might also want to look at [`shiba`](https://github.com/rhysd/Shiba/blob/master/docs/installation.md)


"""""" Using Suan/Vim-instant-Markdown 
" I'm hoping that this will allow me to follow links
"filetype plugin on
"Uncomment to override defaults:
"let g:instant_markdown_slow = 1
"let g:instant_markdown_autostart = 1
"let g:instant_markdown_open_to_the_world = 1
"let g:instant_markdown_allow_unsafe_content = 1
"let g:instant_markdown_allow_external_content = 1
"let g:instant_markdown_mathjax = 1
"let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
"let g:instant_markdown_autoscroll = 0
"let g:instant_markdown_port = 8888
"let g:instant_markdown_python = 1



"Plug 'vimwiki/vimwiki' The extra features are nice
" I only want a markdown wiki so it wil /just/ work with mweb on ios 
" (as well as other apps), vimwiki incorporates /vim-markdown-wiki/ but
" I don't need all the hassle of vimwiki if `vim-markdown-wiki` will just
" work, vimwiki will break putting underscores in and it will break the very
" sensible syntax.
"
":map <leader>ww :e ~/Dropbox/Notes/MD/notes/index.md <CR>

" make this run the 'ns' script as well. or maybe use <leader>ws
" This conflicted with Tocv in Plastic boy,
" I remapped it but normal enter seems to 
" just work with CR anyway so whatever
"nnoremap <S-CR> :MdwiGotoLink 
"nnoremap <leader><CR> :MdwiReturn

" Fix the titles
" function! MdwiWriteTitle(word)
"   "return 'normal!\ a# '.strftime('%c').' - '.escape(a:word, ' \').'\<esc>'
"   return 'normal!\ a#  '.escape(a:word, ' \').'\<esc>'
" endfunction

" Make sure the path has ./ in it for MWeb
   " I changed this here
   " /home/ryan/Dropbox/profiles/.vim/plugged/vim-markdown-wiki/after/ftplugin/markdown.vim
   " ~/.vim/plugged/vim-markdown-wiki/after/ftplugin/markdown.vim






"############################## 
"###### Re Mapping ############ 
"############################## 
""""" Vim-Emoji
"let g:gitgutter_sign_added = emoji#for('small_blue_diamond')
"let g:gitgutter_sign_modified = emoji#for('small_orange_diamond')
"let g:gitgutter_sign_removed = emoji#for('small_red_triangle')
"let g:gitgutter_sign_modified_removed = emoji#for('collision')
"set completefunc=emoji#complete
"for e in emoji#list()
"  call append(line('$'), printf('%s (%s)', emoji#for(e), e))
"endfor


""""" Export Mapping

nmap <Leader>meelo :!pandoc -s --self-contained "%" --listings --toc  -H ~/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape --citeproc --bibliography $HOME/Sync/Documents/ref.bib -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown


nmap <Leader>meeho :!pandoc -s --self-contained "%"  --toc -H ~/Templates/CSS/gitOrgWrapped.css --citeproc --bibliography $HOME/Sync/Documents/ref.bib  --csl ~/Templates/CSL/nature.csl -o /tmp/note.html ; cat ~/Templates/mathjax >> /tmp/note.html; xdg-open /tmp/note.html

nmap <Leader>meehom :!pandoc -s --self-contained "%" --mathml --toc -H ~/Templates/CSS/gitOrgWrapped.css --csl ~/Templates/CSL/nature.csl --citeproc --bibliography $HOME/Sync/Documents/ref.bib  -o /tmp/note.html ;  xdg-open /tmp/note.html


"""" Useful mappings
" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>


" Focus Mode
nnoremap fks :Goyo<CR><CR>

"Enable Auto Save
let g:auto_save = 1  " enable AutoSave on Vim startup
"Silent Save
"let g:auto_save_silent = 1  " do not display the auto-save notification

" Clipboard sharing
" Don't use this, use the remapings at leader-clip-reymap
"set clipboard=unnamedplus
" Maybe us this instead? read :help clipboard
"set clipboard+=unnamed



" Remap F4 to CopyFileDirectory
noremap <silent> <F4> :let @+=expand("%:p")<CR>
"noremap <silent> <leader>fy :let @+=expand("%:p")<CR>
noremap <silent> <leader>fy :! echo "%" \| xargs realpath \| xclip -selection clipboard <CR><CR><CR>
noremap <Leader>fL :! readlink -f "%" \| xclip -selection clipboard
noremap <Leader>gL :
noremap <silent> <leader>fty :let @+=expand("%:t")<CR>


" Return to previous Buffer
"Jump back to last edited buffer
nnoremap <C-b> <C-^>
inoremap <C-b> <esc><C-^>

"Cycle Buffers (p. 64 Mastering Vim)
noremap <C-k> :nohl<CR>
noremap <C-h> :bprev<CR>
map backspace :bprev<CR>
map <leader>bp :bprev<CR>
"noremap <C-j> :bnext<CR>
noremap <C-l> :bnext<CR>
map <Leader>bn :bnext<CR>



"Save Document


"""" Leader Key
"This is probably for the best because matches spacemacs/Doom
"let mapleader="\<Space>"
map <Space> <Leader>

""""" Clipboard-Map
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















""""" Visual Selection

" Run the dot command over visually selected lines
vnoremap . :normal.<CR>

" Move visual selection
  " So the problem with this is it get's rid of 
  " Join so instead, Alt+j/k
"vnoremap J :m '>+1<CR>gv=gv
"vnoremap K :m '<-2<CR>gv=gv

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv



""""" Folding
  set foldenable           "Enable folding
  set nofoldenable           "Enable folding
"  set foldlevelstart=0     "Open most of the folds by default. If set to 0, all folds will be closed.
  set foldnestmax=10       "Folds can be nested. Setting a max value protects you from too many folds.
  set foldmethod=expr    "Defines the type of folding. globally, so if you don't have an 
"                        " Auto method defined, it expects instructions at the
"                        end like in this file
":autocmd BufRead /path/to/file setlocal foldmethod=marker
":autocmd FileType java setlocal foldmethod=marker
":autocmd BufEnter *.tex set foldmethod=manual " This will use the inbuild, but it will let
"                                              fold things manually, like
"                                              equations/code blocks

  let r_syntax_folding=1   "R code folding
  let sh_fold_enabled=1    "Shell Scirpts
" unfourtunately manual folding doesn't work in markdown because plasticboy,
" the following let's plasticboy fold and let's manual folding of say code
" blocks
:map <leader>fm :set foldmethod=manual<CR>


"""" fzf mappings fzf-vim-usage 
"  " Mapping selecting mappings
    nmap <leader><tab> <plug>(fzf-maps-n)  
    xmap <leader><tab> <plug>(fzf-maps-x)
    omap <leader><tab> <plug>(fzf-maps-o)
"
"    " Insert mode completion
    imap <c-x><c-k> <plug>(fzf-complete-word)
    imap <c-x><c-f> <plug>(fzf-complete-path)
    imap <c-x><c-j> <plug>(fzf-complete-file-ag)
    imap <c-x><c-l> <plug>(fzf-complete-line)
"   " Snippets
   nmap  <Leader>s :Snippets<CR>
"   imap  <Leader>s :Snippets<CR>
" Remap FZF
nnoremap <C-p> :<C-u>FZF<CR>
"
"may work in bash/zsh
"inoremap <expr> <c-x><c-f> fzf#vim#complete#path( 
"    \ "find . -path '*/\.*' -prune -o -print \| sed '1d;s:^..::'",
"    \ fzf#wrap({'dir': expand('%:p:h')}))
"
" invoke fzf files with <C-p>
nnoremap <C-p> :<C-u>FZF<CR>
nnoremap <leader>bW :Buffers<CR>
nnoremap <leader>bW :Buffers<CR>

"""" Deoplete Bindings
" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function() abort
"  return deoplete#close_popup() . "\<CR>"
"endfunction

""" Themes 
" Theme Must go at the bottom
set t_Co=256   " This is may or may not needed.

"set background=light
"colorscheme PaperColor
"colorscheme challenger_deep




""" Modeline Folding

" Nah this breaks all the time, instead I'm going to use 2 whitespace
" characters and change > to use 2 white spaces (I know 4 is standed but it's
" going to prohibit deep nesting
" using indent folding also allows manual folding with zfip or zfif (markdown
" plugin)





set modeline
set modelineexpr  "This does all the magic folding
   " This is always enabled in OG vim, in nvim it must be physically enabled
     " Vim will giv a warning about not recognising this command, which is
     " fine because it shouldn't and it notifies us that we are using vim and
     " not nvim. Google "vim modeline vulnerability 2019" for more info 


" Found this [here](https://vi.stackexchange.com/a/3820)


" Found this [here](https://vi.stackexchange.com/a/3820)

" vim:fdm=expr:fdl=0
" vim:fde=getline(v\:lnum)=~'^""'?'>'.(matchend(getline(v\:lnum),'""*')-2)\:'='
"
" Comments MUST be on the first column or this will break, that's the issue
  
