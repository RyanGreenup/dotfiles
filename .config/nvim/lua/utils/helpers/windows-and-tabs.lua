function Open_file_in_split_or_tab(path, insert, split_type)
  -- split
  vim.api.nvim_command(split_type .. " " .. path)

  -- Check that insert isn't empty
  if insert ~= nil then
    if insert ~= "" then
      -- Insert the text
      vim.api.nvim_set_current_line(insert)
      -- Open a new line
      vim.cmd("normal! o")
      vim.cmd("normal! o")
    end
  end
end

function Open_file_in_split(path, insert)
  Open_file_in_split_or_tab(path, insert, "split")
end

function Open_file_in_tab(path, insert)
  Open_file_in_split_or_tab(path, insert, "tabnew")
end

function Move_window_to_tab()
  local current_buffer_name = vim.api.nvim_buf_get_name(0)
  -- Close the window
  vim.cmd("q")
  -- Open in a new tab
  Open_file_in_tab(current_buffer_name, "")
end
