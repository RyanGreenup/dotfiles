--------------------------------------------------------------------------------
-- Open Journal Files ----------------------------------------------------------
--------------------------------------------------------------------------------
function get_recent_journal_files(dir_path)
  -- Get all .md files in the directory using vim.fn.globpath
  local files_string = vim.fn.globpath(dir_path, '*.md')

  -- Split the files string into a table with individual file names
  local file_list = vim.split(files_string, '\n')

  -- Filter the file names to match the date format
  local journal_files = {}
  for _, file in ipairs(file_list) do
    if file:match('%d%d%d%d%-%d%d%-%d%d%.md') then
      table.insert(journal_files, file)
    end
  end

  -- Sort the files in descending order
  table.sort(journal_files, function(a, b) return a > b end)

  -- Return the last 5 files
  -- return { unpack(journal_files, math.max(#journal_files - 4, 1)) }
  -- Return the first 5 files instead
  return { unpack(journal_files, 1, 5) }
end

-- Function to check if there is a split below

function is_split_below()
  local current_win = vim.api.nvim_get_current_win()

  -- Get the position [row, col] and height of the current window
  local _, current_col = unpack(vim.api.nvim_win_get_position(current_win))
  local current_bottom = select(2, unpack(vim.api.nvim_win_get_position(current_win))) +
      vim.api.nvim_win_get_height(current_win)

  -- Loop over all windows
  local all_wins = vim.api.nvim_list_wins()

  for _, win_id in ipairs(all_wins) do
    if win_id ~= current_win then
      -- Get the position [row, col] of the other window
      local _, win_col = unpack(vim.api.nvim_win_get_position(win_id))
      local win_top = select(2, unpack(vim.api.nvim_win_get_position(win_id)))

      -- Return true if another window begins at the same column and below the current window
      if win_col == current_col and win_top >= current_bottom then
        return true
      end
    end
  end
  return false
end

-- Function to resize the windows to golden ratio
function Resize_windows_Golden()
  local ratio = 0.618
  local width = vim.api.nvim_get_option('columns')
  local height = vim.api.nvim_get_option('lines')
  local new_width = math.floor(width * ratio)
  local new_height = math.floor(height * ratio)


  -- Check that there is a split below
  if is_split_below() then
    vim.api.nvim_command('resize ' .. new_height)
  end
  vim.api.nvim_command('vertical resize ' .. new_width)
end

function Open_journals()
  -- Get recent journal files and open them in neovim
  HOME = os.getenv('HOME')
  dir_path = HOME .. '/Notes/slipbox/journals'
  local files = get_recent_journal_files(dir_path)
  for i, file in ipairs(files) do
    print(file)
    -- if the file exists
    if vim.fn.filereadable(file) == 0 then
      goto continue
    end
    -- split
    -- if i is even
    if i % 2 == 0 then
      vim.api.nvim_command('vsplit ' .. file)
    else
      vim.api.nvim_command('split ' .. file)
    end
    -- Open the file
    vim.api.nvim_command('e ' .. file)
    -- If i is 1 and this is the first close the last window
    if i == 1 then
      vim.api.nvim_command('wincmd w')
      vim.api.nvim_command('q')
    else
      -- Resize the window (can't resize the first window)
      Resize_windows_Golden()
    end
    ::continue::
  end
end
