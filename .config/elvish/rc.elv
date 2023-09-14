use re

use readline-binding

use path

use str
use math

# Where all the Go stuff is
var optpaths = [
  ~/.config/emacs/bin
  ~/.cargo/bin
  ~/.nix-profile/bin/
  ~/go/bin
  /var/lib/flatpak/exports/bin/
]
var optpaths-filtered = [(each {|p|
      if (path:is-dir $p) { put $p }
} $optpaths)]

set paths = [
  ~/.local/bin
  ~/Applications/AppImages/bin
  $E:GOPATH/bin
  $@optpaths-filtered
  /usr/bin
  /usr/sbin
  /usr/sbin
  /sbin
  /usr/bin
  /bin
]

each {|p|
  if (not (path:is-dir &follow-symlink $p)) {
    echo (styled "Warning: directory "$p" in $paths no longer exists." red)
  }
} $paths

use epm

epm:install &silent-if-installed         ^
github.com/zzamboni/elvish-modules     ^
github.com/zzamboni/elvish-completions ^
github.com/zzamboni/elvish-themes      ^
github.com/xiaq/edit.elv               ^
github.com/muesli/elvish-libs          ^
github.com/iwoloschin/elvish-packages

#   eval (starship init elvish | sed 's/except/catch/')
# Temporary fix for use of except in the output of the Starship init code
eval (/usr/bin/starship init elvish --print-full-init | slurp)

fn have-external { |prog|
  put ?(which $prog >/dev/null 2>&1)
}

fn only-when-external { |prog lambda|
  if (have-external $prog) { $lambda }
}

only-when-external exa {
  var exa-ls~ = { |@_args|
    use github.com/zzamboni/elvish-modules/util
    e:exa --color-scale --git --group-directories-first (each {|o|
        util:cond [
          { eq $o "-lrt" }  "-lsnew"
          { eq $o "-lrta" } "-alsnew"
          :else             $o
        ]
    } $_args)
  }
  edit:add-var ls~ $exa-ls~
}

var dotfiles_dir = ~/.local/share/dotfiles

fn gd {|@args|
    git --work-tree ~ --git-dir $dotfiles_dir $@args
}

fn gdui {
    gitui  -w ~ -d $dotfiles_dir
}

fn get-os {
    str:trim-space (cat /etc/os-release | grep -e '^ID=' | cut -d '=' -f 2 | sed 's/"//g')
}

fn is-os { |os|
  str:compare (get-os) $os
}


var package-query-map = [

  &arch={|&external_repos=false|
   if $external_repos {
    var packages = [(pacman -Slq | fzf --multi --preview 'pacman -Si {1}' )]
    doas pacman -S $@packages
   } else {
    var packages = [(yay -Slq | fzf --multi --preview 'pacman -Si {1}' )]
    doas pacman -S $@packages
   }
  }

  &void={
    var packages = [(
    xbps-query -Rs '' |
        rg -o '[\w-]+-'  |
        sed 's!-$!!'     |
        fzf --multi --preview 'xbps-query -S {} || echo No Info Available')]
    doas xbps-install $@packages
  }

  &gentoo={ |&external_repos=false|
    if $external_repos {
        var packages = [(eix -Rc | awk '{print $2}' | fzf --multi --preview 'eix --verbose {1}' )]
        doas emerge --ask --verbose $@packages
    } else {
        var packages = [(eix -Rc | awk '{print $2}' | fzf --multi --preview 'eix --verbose {1}' )]
        doas emerge --ask --verbose $@packages
    }
  }
]

fn void-package-query {
    xbps-query -Rs '' |
        rg -o '[\w-]+-'  |
        sed 's!-$!!'     |
        fzf --multi --preview 'xbps-query -S {} || echo No Info Available'
}

fn arch-package-query { |argv|
    pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S $@argv
}

fn gentoo-package-query { |&external_repos=false|
    if $external_repos {
        var packages = [(eix -Rc | awk '{print $2}' | fzf --multi --preview 'eix --verbose {1}' )]
        doas emerge --ask --verbose $@packages
    } else {
        var packages = [(eix -Rc | awk '{print $2}' | fzf --multi --preview 'eix --verbose {1}' )]
        doas emerge --ask --verbose $@packages
    }
}

fn pz {
    use str
    if (== 0 (is-os "void")) {
        echo "You are using void"
        void-package-query
    } elif (== 0 (is-os "arch")) {
        echo TODO
    } elif (== 0 (is-os "endeavouros")) {
        arch-package-query
    } elif (== 0 (is-os "gentoo")) {
        gentoo-package-query
  }
}

fn pZ {
    use str
    if (== 0 (is-os "void")) {
        echo "TODO"
    } elif (== 0 (is-os "arch")) {
        echo "TODO"
    } elif (== 0 (is-os "endeavouros")) {
        echo "TODO"
    } elif (== 0 (is-os "gentoo")) {
        gentoo-package-query &external_repos=true
  }
}

set E:LESS = "-i -R"

set E:EDITOR = "nvim"

set E:LC_ALL = "en_US.UTF-8"

set E:PKG_CONFIG_PATH = "/usr/local/opt/icu4c/lib/pkgconfig"

# var exa-ls~ = { |@_args|
 fn n { |@_args|
        var tmp = (mktemp)
        lf -last-dir-path=$tmp $@_args
        if (test -f $tmp) {
            var dir = (cat $tmp)
            rm -f $tmp
            if (test -d $dir) {
                if (test $dir != (pwd)) {
                    cd $dir
                }
            }
        }
    }

eval (zoxide init elvish | slurp)

eval (carapace _carapace|slurp)

fn is_readline_empty {
  # Readline buffer contains only whitespace.
  re:match '^\s*$' $edit:current-command
}

set edit:insert:binding[Enter] = {
  if (is_readline_empty) {
    # If I hit Enter with an empty readline, it launches fzf with command history
    set edit:current-command = ' edit:histlist:start'
    edit:smart-enter
    # But you can do other things, e.g. ignore the keypress, or delete the unneeded whitespace from readline buffer
  } else {
    # If readline buffer contains non-whitespace character, accept the command.
    edit:smart-enter
  }
}

fn fzf_history {||
  if ( not (has-external "fzf") ) {
    edit:history:start
    return
  }
  var new-cmd = (
    edit:command-history &dedup &newest-first &cmd-only |
    to-terminated "\x00" |
    try {
      fzf --no-multi --height=30% --no-sort --read0 --info=hidden --exact --query=$edit:current-command | slurp
    } catch {
      edit:redraw &full=$true
      return
    }
  )
  edit:redraw &full=$true
  # make sure to trim whitespace so there isn't a new line <https://github.com/elves/elvish/issues/1053#issuecomment-1019418826>
  set edit:current-command = (str:trim-space $new-cmd)
}
set edit:insert:binding[Ctrl-R] = {|| fzf_history >/dev/tty 2>&1 }

fn fzf_files {||
  if ( not (has-external "fzf") ) {
    echo "Install fzf"
    return
  }
  var new-cmd = (
    fd |
    to-terminated "\x00" |
    try {
      fzf --no-multi --height=30% --no-sort --read0 --info=hidden --exact --query=$edit:current-command | slurp
    } catch {
      edit:redraw &full=$true
      return
    }
  )
  edit:redraw &full=$true
  # make sure to trim whitespace so there isn't a new line <https://github.com/elves/elvish/issues/1053#issuecomment-1019418826>
  set edit:current-command = (str:trim-space $new-cmd)}

set edit:insert:binding[Ctrl-t] = {|| fzf_files >/dev/tty 2>&1 }

fn fzf_dirs {||
  if ( not (has-external "fzf") ) {
    echo "Install fzf"
    return
  }
  var new-cmd = (
    fd -t d |
    to-terminated "\x00" |
    try {
      fzf --no-multi --height=30% --no-sort --read0 --info=hidden --exact --query=$edit:current-command | slurp
    } catch {
      edit:redraw &full=$true
      return
    }
  )
  cd (str:trim-space $new-cmd)
  edit:redraw &full=$true
  # make sure to trim whitespace so there isn't a new line <https://github.com/elves/elvish/issues/1053#issuecomment-1019418826>
  # set edit:current-command = (str:trim-space $new-cmd)
}

set edit:insert:binding[Alt-c] = {|| fzf_dirs >/dev/tty 2>&1 }
