# Dotfiles

My dotfiles, now being managed with [Chezmoi](https://github.com/twpayne/chezmoi/blob/master/docs/QUICKSTART.md).

## Usage 
To use these dotfiles, [set chezmoi to use this repo](https://github.com/twpayne/chezmoi/blob/master/docs/QUICKSTART.md#using-chezmoi-across-multiple-machines):

```bash
 chezmoi init https://gitlab.com/projects/new#blank_project
 chezmoi apply
 # in the future update with
 chezmoi update
```

## Seperate

To use only some files, consider creating seperate branches or implementing
a tool like [GNU](https://www.gnu.org/software/stow/).
