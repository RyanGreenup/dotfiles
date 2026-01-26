local function config_yamb()
  -- [h-hg/yamb.yazi: Yet another bookmarks plugins. It supports persistence, jumping by a key, jumping by fzf.](https://github.com/h-hg/yamb.yazi)
  -- You can configure your bookmarks by lua language
  local bookmarks = {}

  local path_sep = package.config:sub(1, 1)
  local home_path = ya.target_family() == "windows" and os.getenv("USERPROFILE") or os.getenv("HOME")
  if ya.target_family() == "windows" then
    table.insert(bookmarks, {
      tag = "Scoop Local",

      path = (os.getenv("SCOOP") or home_path .. "\\scoop") .. "\\",
      key = "p"
    })
    table.insert(bookmarks, {
      tag = "Scoop Global",
      path = (os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop") .. "\\",
      key = "P"
    })
  end
  table.insert(bookmarks, {
    tag = "Desktop",
    path = home_path .. path_sep .. "Desktop" .. path_sep,
    key = "d"
  })

  require("yamb"):setup {
    -- Optional, the path ending with path seperator represents folder.
    bookmarks = bookmarks,
    -- Optional, the cli of fzf.
    cli = "fzf",
    -- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
    keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    -- Optional, the path of bookmarks
    path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
        (os.getenv("HOME") .. "/.config/yazi/bookmark"),
  }
end

local function config_full_border()
  require("full-border"):setup()
end


-- TODO this doesn't work yet
local function clone_plugin(repo, dir, method)
  -- Test if directory exists
  local dirExists = os.execute("[ -d " .. dir .. " ]")

  -- Test if init.lua exists
  local initExists = os.execute("[ -f " .. dir .. "/init.lua ]")

  -- If not found, execute git clone command
  if not dirExists or not initExists then
    if method == "git" then
      local cmd = "git clone " .. repo .. " " .. dir
      os.execute(cmd)
    elseif method == "curl" then
      local cmd = "mkdir -p " .. dir .. " && curl " .. repo .. " > " .. dir .. "/init.lua"
      os.execute(cmd)
    end
  end
end

local function clone_plugins()
  -- Note that plugins must end in .yazi
  local plugins = {
    {
      repo = "https://github.com/h-hg/yamb.yazi.git",
      dir = "~/.config/yazi/plugins/yamb.yazi",
      method = "git"
    },
    {
      repo = "https://raw.githubusercontent.com/yazi-rs/plugins/main/full-border.yazi/init.lua",
      dir = "~/.config/yazi/plugins/full-border.yazi",
      method = "curl"
    },
    {
      repo = "https://github.com/wylie102/duckdb.yazi",
      dir = "~/.config/yazi/plugins/duckdb.yazi/",
      method="git"
    }
  }

  for _, plugin in ipairs(plugins) do
    clone_plugin(plugin.repo, plugin.dir, plugin.method)
  end
end





local function main()
  -- Clone down any plugins (disabled - plugins already installed)
  -- clone_plugins()

  -- Configure Bookmarks
  config_yamb()

  -- Setup Duckdb
  require("duckdb"):setup()
end


main()
