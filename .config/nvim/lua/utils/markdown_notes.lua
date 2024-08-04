local M = {} -- define a table to hold our module


local function title_to_filename(input)
  local out = "cite_" .. input
  out = string.gsub(out, " / ", "_")
  out = string.gsub(out, " ", "-")
  out = string.gsub(out, ":", "-")
  return out .. ".md"
end

local function markdown_link(title, path)
  return "[" .. title .. "](" .. path .. ")"
end


-- Define the function we want to export
function M.make_cite_page()
  local input = vim.fn.input("Enter the name of the citable object (or bibtex key): ")

  -- clean the filename up
  local filename = title_to_filename(input)

  -- Insert a link at the cursor
  vim.api.nvim_put({ markdown_link(input, filename) }, "l", true, true)

  -- Open the file
  vim.cmd("vsplit " .. filename)

  -- Insert a Heading
  vim.api.nvim_put({ "# " .. input }, "l", true, true)
end

-- Return the module table so that it can be required by other scripts
return M
