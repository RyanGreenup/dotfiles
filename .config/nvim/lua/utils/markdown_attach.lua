local M = {} -- define a table to hold our module


--- Create a temporary file
---@return string
local function CreateTempFile()
  local cwd = vim.fn.getcwd()
  local filename = cwd .. "/tmp_chooser_file" .. os.time()
  local f = io.open(filename, "w+") -- w+ mode opens a file for updating (reading and writing)
  return filename
end

--- Read the file
---@param filepath string
---@return string
local function read_file(filepath)
  local f = io.open(filepath, "rb")
  -- Read the file
  local content = f:read("*all") -- reads the whole file
  f:close()
  -- Delete the file
  os.remove(filepath)

  -- remove new line
  content = string.gsub(content, "\n$", "")
  return content
end

--- Check if the file is an image
---@param target_file
---@return boolean
local function is_image(target_file)
  local image_exts = { ".png", ".jpg", ".jpeg" }
  for _, ext in ipairs(image_exts) do
    if string.match(target_file, ext) then
      return true
    end
  end
  return false
end

local function make_link(target_file)
  if is_image(target_file) then
    return "![" .. target_file .. "](" .. target_file .. ")"
  else
    return "[" .. target_file .. "](" .. target_file .. ")"
  end
end

---Logic to insert the target link after Yazi has finished
---@param filepath string
local function on_exit(filepath)
  -- read file into string
  local target_file = read_file(filepath)
  require('notify')("File attached: " .. target_file)
  vim.cmd("bdelete")  -- close the buffer
  os.remove(filepath) -- delete the file

  -- If the file_contents is under the current working directory, insert the relative path
  local cwd = vim.fn.getcwd()
  if string.find(target_file, cwd) then
    target_file = string.gsub(target_file, cwd, ".")
  else
    -- Copy the target_file to .
    os.execute("cp " .. target_file .. " " .. "./assets/")
    target_file = "./assets/" .. vim.fn.fnamemodify(target_file, ":t")
  end

  -- Check if it's an image
  local target_link = make_link(target_file)

  -- insert the line
  vim.api.nvim_put({ target_link }, "l", true, true)
end

---Use yazi to attach a file
local Yazi_attach_file = function()
  local filepath = CreateTempFile()
  local command = "yazi --chooser-file " .. filepath
  -- vim.cmd([[vsplit]])
  -- Need to make
  vim.cmd("new")
  local terminal_buffer = vim.fn.termopen(command, {
    on_exit = function()
      on_exit(filepath)
    end
  })
  vim.cmd("tabnext") -- switch to the new tab
end

function choose_file(opts)
  if opts == nil then
    opts = {}
  end
  if opts.caller == nil then
    opts.caller = "yazi"
  end
  if opts.caller == "yazi" then
    Yazi_attach_file()
  end
end

-- Define the function we want to export
function M.attach_file()
  choose_file()
end

-- Return the module table so that it can be required by other scripts
return M
