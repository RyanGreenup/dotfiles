local cmd = vim.cmd     		-- execute Vim commands

cmd [[ filetype plugin on ]]
cmd [[autocmd BufEnter *.md :map <leader>v  :InstantMarkdownPreview<CR> ]]

-- Uncomment to override defaults:
cmd [[ let g:instant_markdown_slow = 1
       let g:instant_markdown_autostart = 0
       let g:instant_markdown_mathjax = 1
       let g:instant_markdown_allow_unsafe_content = 1
       let g:instant_markdown_mermaid = 1
      "let g:instant_markdown_open_to_the_world = 1
      "let g:instant_markdown_allow_external_content = 0
      "let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
      "let g:instant_markdown_autoscroll = 0
      "let g:instant_markdown_port = 8837
      "let g:instant_markdown_python = 1

    ]]
