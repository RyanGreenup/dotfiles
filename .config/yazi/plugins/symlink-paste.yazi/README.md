# Symlink Paste Plugin

Paste relative symlinks from Yazi's yank buffer with automatic relative path calculation.

## Usage

1. **Yank** (or cut) a file/symlink with `y` (or `x`)
2. Navigate to destination directory
3. Press `g j p` to paste a relative symlink

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
