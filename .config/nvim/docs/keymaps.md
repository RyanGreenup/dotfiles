# Keymaps
## Introduction
Keymaps are set in one of three locations:

1.  `~/.config/nvim/lua/plugins/which-key.lua`
    - Sequence Keymaps
2. `~/.config/nvim/lua/keymaps.lua`
    - Non-Sequence keymaps
    - Autocommand Keymaps
3. `~/.config/nvim/lua/plugins/slime.lua`
    - Slime Keymaps (non autocommands)

## Discussion
### Sequence Keymaps
### Non-Sequence Keymaps
### Slime Keymaps
I wanted to leave these keymaps in that configuration file as I may want to try other plugins other than slime for a lua based solution. This way I can comment out that file and try something else

If needed, it's not hard to roll my own, see e.g. `~/.config/nvim/lua/utils/send_code_zellij.lua`. However, I don't want to deal with the intricacies of sending code to with the intricacies of CRLF, bracketed paste and other pain points. For now it's easier to use slime.
## Future work
### Merging keymaps into which-key
I could use the `cond` parameter of which key to set the keymaps in the `which-key.lua` file. This would centralize all keymaps.

I tried this:


```lua
    {
      "<leader>ns",
      function() Create_markdown_link(true) end,
      desc = "Create a Subpage Link and Open Buffer",
      -- cond =
      --     function()
      --       local file_ext = vim.fn.expand('%:e')
      --       if file_ext ~= nil then
      --         if file_ext == "md" or file_ext == "markdown" then
      --           return true
      --         end
      --       else
      --         return false
      --       end
      --     end
    },
```

But It required continously resourcing which-key, I could do that as an autocommand though, i.e.:

```vim
autocmd BufEnter * so ~/.config/nvim/lua/plugins/which-key.lua
```

Alternatively, I could have one modal keybinding (e.g. <SPC>m that would correspond to the current file, the autocommand could fire on filetype and set the that buffer keymaps (so as to not polute other files keybindings)

### Centralizing Autocommands and Keymaps
I have a file for autocommands and other for keymaps, I should:

1. move all keymaps out of autocommands
2. Create a keymaps_autocommands
