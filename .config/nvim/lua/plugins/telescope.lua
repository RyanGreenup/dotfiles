local telescope = {
  'nvim-telescope/telescope.nvim',
  config = function()
    require('telescope').load_extension('file_browser')
    -- if the fzf native extension is installed, load it
    if pcall(require, 'telescope._extensions.fzf') then
      require('telescope').load_extension('fzf')
    end


    if pcall(require, 'telescope._extensions.lazy') then
      require("telescope").load_extension "lazy"
    end
    require("telescope").setup({
      pickers = {
        colorscheme = {
          enable_preview = true
        }
      }
    })
    -- require('telescope').load_extension('dap')
  end
}

local native_fzf_build_command = [[
  sh -c '
  set -e
  if command -v cmake &> /dev/null; then
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --prefix build
  else
    echo "You need to install cmake to build the fzf native extension"
    echo "Install cmake and then run :Lazy build fzf-native-extension"
    exit 1
  fi
  '
  ]]

local telescope_fzf = {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = native_fzf_build_command
}

return {

  telescope,
  telescope_fzf,
  { "nvim-telescope/telescope-file-browser.nvim" },
  { 'https://github.com/kyazdani42/nvim-web-devicons' },
  { 'https://github.com/camgraff/telescope-tmux.nvim' },

  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'https://github.com/camgraff/telescope-tmux.nvim' },
  { 'https://github.com/kyazdani42/nvim-web-devicons' },
  { 'nvim-telescope/telescope-symbols.nvim' },
  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'tsakirist/telescope-lazy.nvim' },
}
