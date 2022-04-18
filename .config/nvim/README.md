# My Vim Config

It's Lua Based


## Considerations

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
