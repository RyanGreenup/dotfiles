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
gitui -w $HOME -d "${dot_dir}"
```

## Seperate

To use only some files, consider creating seperate branches or implementing
a tool like [GNU](https://www.gnu.org/software/stow/).
