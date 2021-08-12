set PATH /home/ryan/.local/bin $PATH
set PATH /home/ryan/bin $PATH
set PATH /home/ryan/.cargo/bin $PATH
set PATH $HOME/.gem/ruby/2.7.0/bin/ $PATH

# Set Default Editor to Emacs
set VISUAL 'emacs -nw --eval "(add-hook \'emacs-startup-hook #\'sh-mode)"'

# Defined in - @ line 1
function f --wraps='cd ; exa -RGL 3' --description 'alias f=cd; exa -RGL 3'
  cd $argv ; exa -TL 2 ; exa ;
end


## Search for installable Packages
function f --wraps='cd ; exa -RGL 3' --description 'alias f=cd; exa -RGL 3'
  cd $argv ; exa -TL 2 ; exa ;
end


## Better LS
function ls! --wraps='ls -ultrah' --description 'alias ls!=ls -ultrah'
  ls -ultrah $argv;
end


## Easier Xclip
function x --wraps='xclip -selection clipboard' --description 'alias x=xclip -selection clipboard'
  xclip -selection clipboard $argv;
end


## Cadmus Bindings
function ns --wraps='cadmus note search' --description 'alias ns=cadmus note search'
  cadmus note search $argv;
end


function nf --wraps='cadmus note find' --description 'alias ns=cadmus note find'
  cadmus note find $argv;
end


function wa --wraps='cadmus misc w' --wraps='cadmus misc wa' --description 'alias wa=cadmus misc wa'
  cadmus misc wa $argv;
end


function wr --wraps='cadmus misc w' --wraps='cadmus misc waR' --description 'alias wr=cadmus misc wR'
  cadmus misc wR $argv;
end

function no --wraps='cadmus misc code' --description 'alias no=cadmus misc code'
  cadmus misc code $argv;
end

function ng --wraps='cadmus misc atom' --description 'alias ng=cadmus misc atom'
  cadmus misc atom $argv;
end
