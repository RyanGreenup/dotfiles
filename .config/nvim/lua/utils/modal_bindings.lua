--------------------------------------------------------------------------------
-- Modal Layer Keybindings -----------------------------------------------------------
--------------------------------------------------------------------------------

-- Here we define some functions to map to the arrow keys
-- These functions change depending on whether or not a "mode" has been
-- entered.
-- A mode is entered if the Mode variable is set to something
-- Which key has settings for this.

ModalLayer = {
  Organize = "Organize", -- Dayplanner adjustments on tasks
  Resize = "Resize",     -- Window Resizing
  Split = "Split",       -- Splitting windows
  Move = "Move",         -- Normal movement
  Buffer = "Buffer",
  Tabs = "Tabs",
  Git = "Git",
  Search = "Search",
  None = "None",
}

ModalKey = {
  Up = "Up",
  Down = "Down",
  Left = "Left",
  Right = "Right",
  Enter = "Enter",
  M = "m",
  P = "p",
}

ModalCommands = {
  [ModalLayer.Organize] = {
    [ModalKey.Up] = function() Change_dayplanner_line(30) end,
    [ModalKey.Down] = function() Change_dayplanner_line(-30) end,
    [ModalKey.Left] = function() Change_dayplanner_line(-30, true) end,
    [ModalKey.Right] = function() Change_dayplanner_line(30, true) end,
    [ModalKey.M] = function()
      vim.cmd([[normal! vap]])
      vim.cmd([[normal! y]])
      Create_mermaid()
    end,
  },
  [ModalLayer.Split] = {
    [ModalKey.Up] = function()
      vim.cmd("split"); vim.cmd("wincmd k"); vim.cmd("bp")
    end,
    [ModalKey.Down] = function()
      vim.cmd("split"); vim.cmd("wincmd j"); vim.cmd("bp")
    end,
    [ModalKey.Left] = function()
      vim.cmd("vsplit"); vim.cmd("wincmd h"); vim.cmd("bp")
    end,
    [ModalKey.Right] = function()
      vim.cmd("vsplit"); vim.cmd("wincmd l"); vim.cmd("bp")
    end,
  },
  [ModalLayer.Move] = {
    [ModalKey.Up] = function()
      vim.cmd("wincmd k"); Resize_windows_Golden()
    end,
    [ModalKey.Down] = function()
      vim.cmd("wincmd j"); Resize_windows_Golden()
    end,
    [ModalKey.Left] = function()
      vim.cmd("wincmd h"); Resize_windows_Golden()
    end,
    [ModalKey.Right] = function()
      vim.cmd("wincmd l"); Resize_windows_Golden()
    end,
  },
  [ModalLayer.Resize] = {
    [ModalKey.Right] = function() vim.cmd("vertical resize -5") end,
    [ModalKey.Left] = function() vim.cmd("vertical resize +5") end,
    [ModalKey.Down] = function() vim.cmd("resize -5") end,
    [ModalKey.Up] = function() vim.cmd("resize +5") end,
  },
  [ModalLayer.Tabs] = {
    [ModalKey.Up] = function() vim.cmd("tabnew") end,
    [ModalKey.Down] = function() vim.cmd("tabclose") end,
    [ModalKey.Left] = function() vim.cmd("tabprev") end,
    [ModalKey.Right] = function() vim.cmd("tabnext") end,
  },
  [ModalLayer.Buffer] = {
    [ModalKey.Up] = function() vim.cmd("bn") end,
    [ModalKey.Down] = function() vim.cmd("bp") end,
    [ModalKey.Left] = function() vim.cmd("bfirst") end,
    [ModalKey.Right] = function() vim.cmd("blast") end,
  },
  [ModalLayer.Git] = {
    [ModalKey.Up] = function() print("TODO git up") end,
    [ModalKey.Down] = function() print("TODO git down") end,
    [ModalKey.Left] = function() print("TODO git left") end,
    [ModalKey.Right] = function() print("TODO git right") end,
  },
  -- TODO unmap keybindings
  [ModalLayer.None] = {
    [ModalKey.Up] = function() print("TODO none up") end,
    [ModalKey.Down] = function() print("TODO none down") end,
    [ModalKey.Left] = function() print("TODO none left") end,
    [ModalKey.Right] = function() print("TODO none right") end,
    [ModalKey.Enter] = function() print("TODO none enter") end,
    [ModalKey.M] = function() vim.cmd([[normal! m]]) end,
    [ModalKey.P] = function() vim.cmd([[normal! "+p]]) end,
  },
}

function ChangeMode(mode)
  Mode = mode
end

Mode = ModalLayer.Organize








