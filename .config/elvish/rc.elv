use re

use readline-binding

use path

use str
use math

# Where all the Go stuff is
var optpaths = [
  ~/.config/emacs/bin
  ~/.cargo/bin
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
    gitui --polling -w ~ -d $dotfiles_dir
}

fn get-os {
    cat /etc/os-release | grep -e '^ID=' | cut -d '=' -f 2 | sed 's/"//g' | tr -d '\n'
}

fn is-os { |os|
  str:compare (get-os) $os
}

fn void-package-query {
    xbps-query -Rs '' |
        rg -o '[\w-]+-'  |
        sed 's!-$!!'     |
        fzf --multi --preview 'xbps-query -S {} || echo No Info Available'
}

fn arch-package-query { |argv|
    pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S $@argv
}

fn pz {
    use str
    if (== 0 (is-os "void")) {
        echo "You are using void"
        void-package-query
    } elif (== 0 (is-os "arch")) {
        echo TODO
    } elif (== 0 (is-os "endeavouros")) {
        echo TODO
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

var fzf_dirs = { fd -t d | fzf --height 50% }
fn c {
    if (var dir = ($fzf_dirs)) {
        cd $dir
    }
}

eval (zoxide init elvish | slurp)
