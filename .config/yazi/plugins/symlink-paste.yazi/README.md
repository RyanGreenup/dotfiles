# Symlink Paste Plugin

Paste relative symlinks from Yazi's yank buffer with automatic relative path calculation.

## Installation

Copy `main.lua` into `~/.config/yazi/plugins/symlink-paste.yazi/` and add the following to `~/.config/yazi/keymap.toml`:

```toml

# Journal operations
[[mgr.prepend_keymap]]
on = ["g", "j", "g"]
run = "plugin journal"
desc = "Go to today's journal"

[[mgr.prepend_keymap]]
on = ["g", "j", "p"]
run = "plugin symlink-paste"
desc = "Paste relative symlink in journal"

```


## Usage

1. Change into `~/Sync/journals/yyyy/mm/dd` with `g j g`
2. **Yank** (or cut) a file/symlink with `y` (or `x`)
3. Open a new tab with `t`
4. Navigate to destination directory
5. Press `g j p` to paste a relative symlink

## Modes

- **Yank mode (`y`)**: Creates a relative symlink to the yanked file/symlink
- **Cut mode (`x`)**: Creates a relative symlink and deletes the original (symlinks only; regular files are skipped)

## Examples

```
Yank symlink at /home/user/projects/source -> /home/user/data
Paste in /home/user/data/subdir
Result: /home/user/data/subdir/source -> ../../projects/source
```

Perfect for managing symlink farms from a central journal/note directory.


