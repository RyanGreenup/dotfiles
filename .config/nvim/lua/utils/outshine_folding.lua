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

--- Finds the fold level of the nearest marker above the current position
--- @return number|nil The fold level of the marker above, or nil if not found
local function find_level_above()
    local current_line = vim.fn.line('.')
    local pattern = "{{{(%d+)"
    
    -- Search backwards from current line
    for lnum = current_line - 1, 1, -1 do
        local line = vim.fn.getline(lnum)
        local level = line:match(pattern)
        if level then
            return tonumber(level)
        end
    end
    
    return nil
end

--- Adds a marker at the same level as the marker above (or level 1 if none found)
--- @param include_end boolean|nil Whether to include the closing marker (default: false)
function M.add_marker_equal(include_end)
    local level_above = find_level_above()
    local level = level_above or 1
    M.add_markers(level, include_end)
end

--- Adds a marker at one level below the marker above (or level 1 if none found)
--- @param include_end boolean|nil Whether to include the closing marker (default: false)
function M.add_marker_below(include_end)
    local level_above = find_level_above()
    local level = level_above and math.min(level_above + 1, 9) or 1
    M.add_markers(level, include_end)
end

--- Finds the current fold level at the cursor position
--- @return number|nil The fold level of the current section
local function get_current_level()
    local current_line = vim.fn.line('.')
    local pattern = "{{{(%d+)"
    
    -- First check current line
    local line = vim.fn.getline(current_line)
    local level = line:match(pattern)
    if level then
        return tonumber(level)
    end
    
    -- If not on a marker, find the level above
    return find_level_above()
end

--- Jump to the next sibling marker (same level)
function M.goto_next_sibling()
    local current_level = get_current_level()
    if not current_level then
        vim.notify("No fold marker found", vim.log.levels.WARN)
        return
    end
    
    local current_line = vim.fn.line('.')
    local last_line = vim.fn.line('$')
    local pattern = "{{{(" .. current_level .. ")%s*$"
    
    -- Search forward for same level marker
    for lnum = current_line + 1, last_line do
        local line = vim.fn.getline(lnum)
        if line:match(pattern) then
            vim.fn.cursor(lnum, 1)
            vim.cmd('normal! ^')
            return
        end
    end
    
    vim.notify("No next sibling found (level " .. current_level .. ")", vim.log.levels.INFO)
end

--- Jump to the previous sibling marker (same level)
function M.goto_prev_sibling()
    local current_level = get_current_level()
    if not current_level then
        vim.notify("No fold marker found", vim.log.levels.WARN)
        return
    end
    
    local current_line = vim.fn.line('.')
    local pattern = "{{{(" .. current_level .. ")%s*$"
    
    -- Search backward for same level marker
    for lnum = current_line - 1, 1, -1 do
        local line = vim.fn.getline(lnum)
        if line:match(pattern) then
            vim.fn.cursor(lnum, 1)
            vim.cmd('normal! ^')
            return
        end
    end
    
    vim.notify("No previous sibling found (level " .. current_level .. ")", vim.log.levels.INFO)
end

--- Jump to the parent marker (one level up)
function M.goto_parent()
    local current_level = get_current_level()
    if not current_level then
        vim.notify("No fold marker found", vim.log.levels.WARN)
        return
    end
    
    if current_level == 1 then
        vim.notify("Already at top level", vim.log.levels.INFO)
        return
    end
    
    local parent_level = current_level - 1
    local current_line = vim.fn.line('.')
    local pattern = "{{{(" .. parent_level .. ")%s*$"
    
    -- Search backward for parent level marker
    for lnum = current_line - 1, 1, -1 do
        local line = vim.fn.getline(lnum)
        if line:match(pattern) then
            vim.fn.cursor(lnum, 1)
            vim.cmd('normal! ^')
            return
        end
    end
    
    vim.notify("No parent found (level " .. parent_level .. ")", vim.log.levels.INFO)
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
