local M = {}

function M.get_fold_level(lnum)
    local line = vim.fn.getline(lnum)
    
    -- Simple pattern: any line starting with comment + {{{ + number
    -- Examples: // {{{1  or  # {{{2  or  -- {{{3
    local level = line:match("^%s*[/#%-\"%%]*%s*{{{(%d+)")
    if level then
        return ">" .. level
    end
    
    -- Close fold marker
    if line:match("^%s*[/#%-\"%%]*%s*}}}") then
        return "<1"
    end
    
    return "="
end

function M.enable()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.require('utils.outshine_folding').get_fold_level(v:lnum)"
    vim.wo.foldlevel = 0
    vim.opt.foldlevelstart = 0
    print("Outshine folding enabled")
end

function M.disable()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldlevel = 99
    vim.opt.foldlevelstart = 99
    print("LSP/Treesitter folding enabled")
end

function M.toggle()
    if vim.wo.foldexpr == "v:lua.require('utils.outshine_folding').get_fold_level(v:lnum)" then
        M.disable()
    else
        M.enable()
    end
end

function M.setup()
    vim.api.nvim_create_user_command('OutshineEnable', M.enable, {})
    vim.api.nvim_create_user_command('OutshineDisable', M.disable, {})
    vim.api.nvim_create_user_command('OutshineToggle', M.toggle, {})
end

return M