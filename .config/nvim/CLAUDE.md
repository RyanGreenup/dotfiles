# Neovim Config

## Repository

This directory is tracked by a bare git dotfiles repo:
- Git dir: `~/.local/share/dotfiles`
- Work tree: `$HOME`
- Use `gd` (fish shell alias) instead of `git` for dotfiles operations, e.g. `gd status`, `gd add`, `gd commit`.

## Protected Files

`.claude/` and `CLAUDE.md` must never be committed to the dotfiles repo. A pre-commit hook enforces this.
