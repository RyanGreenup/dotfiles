local dap = require('dap')
local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

-- These are copied from https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
-- Python
local python_path = io.popen('which python'):read("*a")
dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return '/usr/bin/python'
    end;
  },
}

dap.adapters.python = {
  type = 'executable';
  command = '/usr/bin/python';
  args = { '-m', 'debugpy.adapter' };
}

-- Julia

dap.configurations.julia = {
  {
    type = 'julia';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return '/usr/bin/julia'
    end;
  },
}

dap.adapters.python = {
  type = 'executable';
  command = '/usr/bin/julia';
  args = { '-m', 'debugpy.adapter' };
}

-- Go
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = {'dap', '-l', '127.0.0.1:${port}'},
  }
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "delve",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

-- C/C++/Rust (requires lldb installation)
local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    -- runInTerminal = false,
  },
}

-- Keybindings to Match VSCode
map( "n", "<F4>", ":lua require('dapui').toggle()<CR>", default_opts          )
map( "n", "<F9>", ":lua require('dap').toggle_breakpoint()<CR>", default_opts )

map( "n", "<F5>", ":lua require('dap').continue()<CR>", default_opts   )
map( "n", "<F10>", ":lua require('dap').step_over()<CR>", default_opts )
map( "n", "<F11>", ":lua require('dap').step_into()<CR>", default_opts )
map( "n", "<F23>", ":lua require('dap').step_out()<CR>", default_opts  ) -- Shift+F11
