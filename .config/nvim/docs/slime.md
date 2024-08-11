# Notes

## Keybindings

### Defaults

| Command                 | Key                | Similar to       | Description                |
|-------------------------+--------------------+------------------+----------------------------|
| SlimeSendCell           | <M-S-CR>           | Rstudio*         | *<C-S-CR> blocks kitty     |
| SlimeSendLine           | <S-CR>             | Pycharm / VSCode | Send the current line      |
| SlimeSendParagraph      | <S-CR>             | "                | Send the current paragraph |
| SlimeSendRegion         | <S-CR>             | "                | Send the current region    |
| SlimeSendBuffer         | <C-M-CR>           | "                | Send the whole buffer      |
| send_all_markdown_cells | <C-M-R>            | Rstudio          | Send all markdown Cells    |
| send_markdown_cell      | <M-S-CR>           | Rstudio          | Send all markdown Cells    |
| SlimeConfig             | <M-x :SlimeConfig> |                  | Configure the target pane  |

### Markdown

Markdown keybindings are set by an autocommand under keymaps.lua

## Config Details

### Cells

Markdown Cells are not managed by slime, rather my own config is used from
utils/markdown_code_cells.lua . This is because I want to dynamically change the
language.

### Simpler Bindings
Originally I was using the following:

```lua
-- Simpler Custom Bindings -------------------------------------------------------------
-- Send everything
vim.cmd [[ nmap <M-S-CR> gg0vG$<Plug>SlimeRegionSend<C-o>zz ]]
-- Send Cell
vim.cmd [[ nmap ?```v/```k<Plug>SlimeRegionSend<C-o>zz ]]
```
However, I eventually relented and wrote up the more rigorous lua.

