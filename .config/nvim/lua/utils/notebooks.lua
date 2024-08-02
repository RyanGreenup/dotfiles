local M = {}

local function n(string)
  require('notify')(string)
end

local function on_output(jobid, data, event)
  -- Needed 2 or copped empty lines :shrug:
  if #data < 2 then
    return
  end
  local s = ""
  for _, line in ipairs(data) do
    s = s .. "\n" .. line
  end
  if s ~= "" then
    print("foo")
    print(s)
  end
end

local function jobstart(command)
  if type(command) == "string" then
    print(command)
  elseif type(command) == "table" then
    print(table.concat(command, " "))
  end
  vim.fn.jobstart(command, {
    on_stdout = vim.schedule_wrap(function(...) on_output(...) end),
    on_stderr = vim.schedule_wrap(function(...) on_output(...) end),
  })
end

local exts = { "r", "py", "rmd", "ipynb"}
local get_format_string = function(percent)
  if percent == nil then
    percent = true
  end
  local opt = ""
  if percent then
    local opt = ":percent"
  end

  local format_string = ""
  for _, ext in ipairs(exts) do
    if ext == "r" then
      format_string = format_string .. "r" .. opt .. ","
    elseif ext == "py" then
      format_string = format_string .. "py" .. opt .. ","
    else
      format_string = format_string .. ext .. ","
    end
    return format_string
  end
end

local function Revert_buffer_pairs()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= nil then
      local fileext = vim.fn.fnamemodify(
        vim.api.nvim_buf_get_name(buf),
        ":e")
      for _, buf_ext in ipairs(exts) do
        if string.lower(fileext) == string.lower(buf_ext) then
          require('notify')(fileext .. buf_ext)
          vim.api.nvim_buf_call(buf, function() vim.cmd("e!") end)
        end
      end
    end
  end
end

local function jupytext_sync()
  local job_id = jobstart({ "jupytext", "--sync", vim.fn.expand("%") })
  -- Revert when the job finishes
  return job_id
end


-- Pairs notebooks into a python and R script and Rmd and ipynb
-- The one_script argument checks the extension and only creates one
-- script file (defaulting to python)
local function jupytext_set_formats(one_script)
  if one_script == nil then
    one_script = false
  end

  -- Include both an R and Python file
  local formats = "r:percent,py:percent,Rmd,ipynb"

  -- Unless the user wants a single script
  if one_script then
    -- Take the extension of the file for the script
    -- TODO consider simply including both r:percent and py:percent
    -- So we can use both languages?
    local ext = vim.fn.expand("%:e")
    formats = ext .. ":percent,Rmd,ipynb"

    -- Unless it's a notebook
    local non_scripts = { "md", "Rmd", "ipynb", "qmd", "quarto", "org", "tex" }
    for _, v in ipairs(non_scripts) do
      if ext == v then
        formats = "py:percent,Rmd,ipynb"
      end
    end
  end

  -- Now pair the notebook
  local job_id = jobstart({ "jupytext", "--set-formats", formats,
    vim.fn.expand("%") })
end

-- Run Jupytext --sync every time one of the files changes
-- Inspect output with :messages
local function jupytext_watch_sync()
  cmd = "ls " .. vim.fn.expand("%:r") .. "* | entr -n jupytext --sync " .. vim.fn.expand("%")
  n(cmd)
  -- vim.cmd("! " .. cmd)
  local job_id = jobstart(cmd)
end

local function open_in_vscode(ext)
  local file = vim.fn.expand("%")
  if ext ~= nil then
    file = vim.fn.expand("%:r") .. "." .. ext
  end
  jobstart({ "codium", file })
end

--[[
Use nbconvert or quarto to render markdown quarto can make a nicer outputs too
This function will detect a file with the same name but an ipynb or Rmd
extension and use either quarto or jupyter to render it If the current file is R the kernel will be changed
--]]
local function jupytext_render_markdown(use_quarto, open_markdown)
  -- Default Variables
  if use_quarto == nil then
    use_quarto = false
  end
  if open_markdown == nil then
    open_markdown = false
  end

  local kernel = ""
  if string.lower(vim.fn.expand("%:e")) == "r" then
    kernel = "--ExecutePreprocessor.kernel_name=ir"
    require('notify')(string.lower(vim.fn.expand(":e")))
  end

  -- Render markdown with quarto or jupyter
  if use_quarto then
    jupytext_sync()
    -- don't use --cached with quarto as it will switch from quarto to jupyter rendering
    local cmd = "quarto render " .. vim.fn.expand("%:r") .. ".Rmd --cache --to gfm"
    vim.cmd("! " .. cmd)
    -- Consider async
    -- jobstart({ "quarto", "render", vim.fn.expand("%:r.Rmd"), "--to", "gfm" })
  else
    -- how to pass --kernel ir to jupyter?
    local cmd = "jupyter nbconvert " .. vim.fn.expand("%:r") .. ".ipynb " .. kernel .." --execute  --to markdown"
    require('notify')(cmd)
    vim.cmd("! " .. cmd)
  end

  -- Open the markdown
  if open_markdown then
    vim.cmd("edit! " .. vim.fn.expand("%:r") .. ".md")
  end
end

local default_quarto_port = 44447
-- Preview with Quarto on Specified Port
local function quarto_preview(port)
  if port == nil then
    port = default_quarto_port
  end

  -- check if an rmd file exists
  local file = vim.fn.expand("%:r") .. ".Rmd"
  if vim.fn.filereadable(file) == 0 then
    n("No Rmd file found, Setting formats with jupytext")
    jupytext_set_formats()
    -- wait 5 seconds
    vim.cmd [[sleep 1]]
  end

  -- Now preview
  jobstart({ "quarto", "preview", vim.fn.expand("%:r") .. ".Rmd", "--port", port })
end


function M.jupytext_set_formats()
  jupytext_set_formats()
end

function M.quarto_preview(port)
  if port == nil then
    port = default_quarto_port
  end

  quarto_preview()
  n("Previewing with Quarto on http://localhost:" .. default_quarto_port)
end

function M.jupytext_sync()
  jupytext_sync()
end

function M.jupytext_sync()
  jupytext_sync()
end

function M.jupytext_watch_sync()
  jupytext_watch_sync()
end

function M.open_in_vscode(extension)
  if extension == nil then
    extension = "ipynb"
  end
  open_in_vscode(extension)
end

function M.jupytext_render_markdown_with_quarto(use_quarto)
  if use_quarto == nil then
    use_quarto = true
  end
  jupytext_render_markdown(use_quarto)
end

function M.jupytext_render_markdown_with_jupyter(use_quarto)
  if use_quarto == nil then
    use_quarto = false
  end
  jupytext_render_markdown(use_quarto)
end

-- Reverts buffers that have one of the extensions
function M.Revert_buffer_pairs()
    Revert_buffer_pairs()
end

return M
