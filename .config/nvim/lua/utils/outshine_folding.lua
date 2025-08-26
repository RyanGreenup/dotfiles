local M = {}

-- {{{1
-- }}}
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

--- Adds outshine folding markers around the current visual selection or line
--- @param level number|nil The fold level (default: 1)
--- @param include_end boolean|nil Whether to include the closing marker (default: false)
function M.add_markers(level, include_end)
    level = level or 1
    include_end = include_end or false
    local mode = vim.fn.mode()
    local comment = vim.bo.commentstring:gsub('%%s', ''):gsub('%s*$', '')
    
    -- If comment string is empty, try to detect based on filetype
    if comment == '' then
        local ft = vim.bo.filetype
        local comment_map = {
            lua = '--',
            python = '#',
            javascript = '//',
            typescript = '//',
            c = '//',
            cpp = '//',
            java = '//',
            rust = '//',
            go = '//',
            vim = '"',
            sh = '#',
            bash = '#',
            zsh = '#',
        }
        comment = comment_map[ft] or '#'
    end
    
    if mode == 'v' or mode == 'V' then
        -- Visual mode: wrap selection
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        
        -- Add opening marker above selection
        vim.fn.append(start_line - 1, comment .. ' {{{' .. level)
        
        if include_end then
            -- Add closing marker below selection (accounting for the added line)
            vim.fn.append(end_line + 1, comment .. ' }}}')
        end
        
        -- Exit visual mode
        vim.cmd('normal! <Esc>')
    else
        -- Normal mode: add markers on current line
        local current_line = vim.fn.line('.')
        local line_content = vim.fn.getline(current_line)
        
        -- Check if line already has content
        if line_content:match('%S') then
            -- Add opening marker above current line
            vim.fn.append(current_line - 1, comment .. ' {{{' .. level)
            if include_end then
                vim.fn.append(current_line + 1, comment .. ' }}}')
            end
        else
            -- Empty line: just add the opening marker
            vim.fn.setline(current_line, comment .. ' {{{' .. level)
            if include_end then
                vim.fn.append(current_line, comment .. ' }}}')
            end
        end
    end
    
    local msg = 'Added fold marker' .. (include_end and 's' or '') .. ' (level ' .. level .. ')'
    vim.notify(msg)
end

--- Adds outshine folding markers with closing marker
--- @param level number|nil The fold level (default: 1)
function M.add_markers_with_end(level)
    M.add_markers(level or 1, true)
end

--- Prompts for fold level and adds markers
function M.add_markers_prompt()
    vim.ui.input({
        prompt = 'Fold level (1-9): ',
        default = '1',
    }, function(input)
        if input then
            local level = tonumber(input)
            if level and level >= 1 and level <= 9 then
                M.add_markers(level)
            else
                vim.notify('Invalid fold level. Please use 1-9', vim.log.levels.WARN)
            end
        end
    end)
end

function M.setup()
    vim.api.nvim_create_user_command('OutshineEnable', M.enable, {})
    vim.api.nvim_create_user_command('OutshineDisable', M.disable, {})
    vim.api.nvim_create_user_command('OutshineToggle', M.toggle, {})
    vim.api.nvim_create_user_command('OutshineAddMarkers', function(opts)
        local level = tonumber(opts.args)
        if level then
            M.add_markers(level)
        else
            M.add_markers_prompt()
        end
    end, { nargs = '?' })
end

return M
