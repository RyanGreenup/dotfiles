# My Vim Config

It's Lua Based

## Setup

This should work out of the box, just start neovim and it will self-configure. Below are some Exceptions:

1. **_R_**
   1. Open R
   2. Install Deps
      ```r
      install.packages(stringi)
      # This probably is not necessary, however, it serves as a nice checkhealth
      install.packages(tidyverse)
      ```
   3. Open Neovim

      ```
      :LSPInstall r_language_server
      ```

      This will take a while ~10 minutes on a slow machine.

## Dependencies

- `tree-sitter-cli` - Required by nvim-treesitter (main branch) to compile parsers. Without it, parsers will re-download and fail to compile on every startup.
  ```sh
  # Arch Linux
  sudo pacman -S tree-sitter-cli

  # or via npm
  npm install -g tree-sitter-cli

  # or via cargo
  cargo install tree-sitter-cli
  ```

## Considerations

### Julia

See [Julia Sys Images](./julia_images.md).

### Snippets

I went with:

- [SerVer/ultisnips]](https://github.com/SirVer/ultisnips)
- [Honza/vim-snippets](https://github.com/honza/vim-snippets/tree/master/UltiSnips)
- [Castel Dev's Snippets](https://github.com/gillescastel/latex-snippets)

because the CastelDev snippets are really good and I didn't
want to reimplement them, these have just been copied in and I'll check the repo ocassionally for any updates.

To get additional snippets I did something like:

```fish
cd (mktemp -d)
git clone https://github.com/honza/vim-snippets/
cp ~/.config/nvim/Ultisnips/tex.snippets /tmp/
cp vim-snippets/UltiSnips/* ~/.config/nvim/UltiSnips/
cp /tmp/tex.snippets ~/.config/nvim/Ultisnips/
```

Again this isn't as clean as using:

- 'L3MON4D3/LuaSnip'
- "rafamadriz/friendly-snippets"
- 'saadparwaiz1/cmp_luasnip'
- 'hrsh7th/nvim-cmp'

but the tex snippets are that good, difficult to reimplement and i'm familiar with the ultisnips package so
I'll leave well enough alone there for the moment.

### SQL Language Server (sqlls)

For SQL completions, sqlls requires a `.sqllsrc.json` config file in your project root:

```json
{
  "name": "my-project",
  "adapter": "sqlite3",
  "filename": "./database.sqlite"
}
```

**Important:** Tables must have aliases to get column completions:

```sql
-- This works (column completions appear):
SELECT i.sepal_width FROM iris i;

-- This does NOT show column completions:
SELECT sepal_width FROM iris;
```

Adapters: `sqlite3`, `mysql`, `postgres`, `bigquery`

**Limitation:** sqlls does NOT support SSL for PostgreSQL connections. The `ssl` config option is ignored - the source code doesn't pass it to the pg client. For managed databases requiring SSL, you'll need an SSH tunnel or local proxy.

### Treesitter and VimTex

### Why Snippy

### Problems with LuaSnip

### Ultisnips and vimtex

in theory could be done with snippy (or luasnip) and lua based config.

using ultisnips means vim+nvim are fine and no need to rewrite config.
