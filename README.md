# Dotfiles

My dotfiles, now being managed with a [bare git repo](https://gitlab.com/RyanGreenup/bare_dot_go).

## Usage
To use these dotfiles:

```bash
git_repo="https://gitlab.com/ryangreenup/dotfiles"
tmp_dot_dir="$(mktemp -d)"
dot_dir="$HOME/.local/share/dotfiles"
git clone --separate-git-dir="${dot_dir}" "${git_repo}" "${tmp_dot_dir}"
rsync --recursive --verbose --exclude '.git' "${tmp_dot_dir}"/ $HOME/

alias gd='git --work-tree $HOME --git-dir $dotfiles_dir $argv'
gd config --local status.showUntrackedFiles no
gd reset --hard

gitui -w $HOME -d "${dot_dir}"
```

## Dependencies

Requires Nerdfonts:

| Distro | Source |
| ---    | ---    |
| FreeBSD | [x11-fonts/nerd-fonts](https://www.freshports.org/x11-fonts/nerd-fonts/)|
| Arch | [nerd-fonts-complete (AUR)](https://aur.archlinux.org/packages/nerd-fonts-complete)
| MacOS | [brew](https://github.com/Homebrew/homebrew-cask-fonts) |
| Windows | [choco ???](https://community.chocolatey.org/packages/nerdfont-hack)|
| OpenBSD | ↓ |

### OpenBSD
Something like this might work:

<details>

```
COMMENT =	Iconic font aggregator, collection, & patcher

# version numbers listed in README.md
DISTNAME =	chivo-1.007
REVISION =	0

CATEGORIES =	fonts

GH_ACCOUNT =	ryanoasis
GH_PROJECT =	nerd-fonts
GH_TAGNAME =    v2.1.0

HOMEPAGE =	https://www.nerdfonts.com/
MAINTAINER =	Ryan G <>

# SIL OFL 1.1
PERMIT_PACKAGE =	Yes

PKG_ARCH =	*

NO_BUILD =	Yes

NO_TEST =	Yes

FONTDIR =	${PREFIX}/share/fonts/${GH_PROJECT}
DOCDIR =	${PREFIX}/share/doc/${GH_PROJECT}

do-install:
	${INSTALL_DATA_DIR} ${FONTDIR} ${DOCDIR}
	${INSTALL_DATA} ${WRKDIST}/nerd-fonts/patched-fonts/*/complete/*.ttf ${FONTDIR}
	${INSTALL_DATA} ${WRKDIST}/nerd-fonts/patched-fonts/*/complete/*.otf ${FONTDIR}

.include <bsd.port.mk>
```

</details>


## Seperate

To use only some files, consider creating seperate branches or implementing
a tool like [GNU](https://www.gnu.org/software/stow/).


## Neovim Dependencies

### Alpine
#### fzf-telescope
On alpine fzf-telescope native depends on:


```bash
apk add                     \
  cmake                     \
   gcc                      \
  clang                     \
  gcc-arm-none-eabi         \
  gcc-arm-none-eabi-stage1  \
  gcc-riscv-none-elf        \
  gcc-riscv-none-elf-stage1 \
  musl-dev                  \
  pcc-libs-dev              \
  rust
```
#### Org Mode

```bash
apk add                     \
  man-pages                 \
  g++
```
