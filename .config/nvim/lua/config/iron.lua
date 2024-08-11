local iron = require("iron.core")

iron.setup {
  config = {
    -- Highlights the last sent block with bold
    highlight_last = "IronLastSent",

    -- Toggling behavior is on by default.
    -- Other options are: `single` and `focus`
    visibility = require("iron.visibility").toggle,

    -- Scope of the repl
    -- By default it is one for the same `pwd`
    -- Other options are `tab_based` and `singleton`
    scope = require("iron.scope").path_based,

    -- Whether the repl buffer is a "throwaway" buffer or not
    scratch_repl = false,

    -- Automatically closes the repl window on process end
    close_window_on_exit = true,

    -- Repl position. Check `iron.view` for more options,
    -- currently there are four positions: left, right, bottom, top,
    -- the param is the width/height of the float window
    repl_open_cmd = 'belowright 15 split',
    -- Alternatively, pass a function, which is evaluated when a repl is open.
    --     repl_open_cmd = require('iron.view').curry.right(function()
    --         return vim.o.columns / 3
    --     end),
    -- iron.view.curry will open a float window for the REPL.
    -- alternatively, pass a string of vimscript for opening a fixed window:
    --     repl_open_cmd = 'belowright 15 split',

    -- If the repl buffer is listed
    buflisted = true,
    -- REPL definitions
    repl_definition = {
      -- python doesn't work properly, ipython does, something about
      -- bracketed paste. ptpython drops a new line requiring an additional
      -- <C-w>l<CR>
      python = {
        command = { "ipython" },
        format = require("iron.fts.common").bracketed_paste,
      },
      sh = {
        command = { "dash" }
      },
      julia = {
        command = function()
          return { 'julia', '--threads=auto', '-J', os.getenv('HOME')..'/.julia/environments/Current/JuliaSysimage.so' }
        end
      },
      ion = {
        command = { "ion" }
      },
      elvish = {
        command = { "elvish" }
      },
      fish = {
        command = { "fish" }
      },
      go = {
        command = { "yaegi" }
      },
      rust = {
        command = { "evcxr" }
      },
      c = {
        command = { "picoc", "-i" }
      },
      cpp = {
        command = { "cling" }
      },
      ruby = {
        command = { "irb" }
      },
    },
    -- how the REPL window will be opened, the default is opening
    -- a float window of height 40 at the bottom.
  },

  -- All the keymaps are set individually
  -- Below is a suggested default
  keymaps = {
    send_motion = "<space>sc",
    visual_send = "<space>sc",
    send_file = "<space>sf",
    send_line = "<space>sl",
    send_mark = "<space>sm",
    mark_motion = "<space>mc",
    mark_visual = "<space>mc",
    remove_mark = "<space>md",
    cr = "<space>s<cr>",
    interrupt = "<space>s<space>",
    exit = "<space>sq",
    clear = "<space>cl",
  },

  -- If the highlight is on, you can change how it looks
  -- For the available options, check nvim_set_hl
  highlight = {
    italic = false
  }
}


vim.cmd [[
 nmap <A-return> <space>sc$
 imap <A-return> <Esc><space>sc$i

 nmap <M-CR> <space>sl
 nmap <C-CR> <space>slj
]]
