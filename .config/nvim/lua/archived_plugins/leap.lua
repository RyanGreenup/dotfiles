return {
  use { 'ggandor/leap.nvim', config = function()
    require('leap').add_default_mappings()
    -- require('leap').leap { target_windows = { vim.fn.win_getid() } }
  end }
}
