local iron = require('iron')

iron.core.add_repl_definitions {
  python = {
    mycustom = {
      command = {"mycmd"}
    }
  },
  clojure = {
    lein_connect = {
      command = {"lein", "repl", ":connect"}
    }
  }
}

iron.core.set_config {
  preferred = {
    python = "ipython",
    clojure = "lein"
  }
}

local cmd = vim.cmd     				-- execute Vim commands


cmd [[
    nmap <leader>rt    <Plug>(iron-send-motion)
    vmap <leader>rv    <Plug>(iron-visual-send)
    nmap <leader>rr    <Plug>(iron-repeat-cmd)
    nmap <leader>rl    <Plug>(iron-send-line)
    nmap <leader>r<CR> <Plug>(iron-cr)
    nmap <leader>ri    <plug>(iron-interrupt)
    nmap <leader>rq    <Plug>(iron-exit)
    nmap <leader>rc    <Plug>(iron-clear)
    nmap <leader>rf    <Plug>(iron-focus)

    nnoremap <Leader>rr :IronRepl<CR>

    vmap <C-c><C-r> <Plug>(iron-visual-send)
    nmap <C-c><C-j> <Plug>(iron-send-line)

]]

