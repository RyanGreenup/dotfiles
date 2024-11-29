# Toggle Autosave


## Old approach

In the past I used this:

```lua
-- Enable Autosave using CursorHold
vim.cmd [[
    :set updatetime=300
    :au CursorHold * :silent! wa
]]

-- Write a function to toggle it
local auto_save = true
function ToggleAutoSave()
  if auto_save then
    vim.cmd [[ :au! ]]
    auto_save = false
    vim.cmd("echo 'Auto-save is OFF'")
  else
    vim.cmd [[ :au CursorHold * :silent! wa ]]
    auto_save = true
    vim.cmd("echo 'Auto-save is ON'")
  end
end

```

However, I found myself constantly hitting escape to get a markdown preview in VSCode. Obviously something like "iamcco/markdown-preview.nvim" would be better, but VSCode is my main markdown previewer already.

For that reason `toggle_autosave.lua` now uses `{ "TextChanged", "TextChangedI" }`.

