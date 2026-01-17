-- sort-folds.lua - Plugin initialization for sort-folds
-- Maintainer:   Oliver Breitwieser
-- License:      MIT license

-- Prevent loading plugin twice
if vim.g.loaded_sort_folds == 1 then return end
vim.g.loaded_sort_folds = 1

-- Set default configuration if not already set
if vim.g.sort_folds_ignore_case == nil then vim.g.sort_folds_ignore_case = 0 end

-- Create the :SortFolds command
vim.api.nvim_create_user_command('SortFolds', function(opts)
    local sortline = tonumber(opts.args) or 0
    local start_line = opts.line1
    local end_line = opts.line2
    require('sort-folds').sort_folds_range(start_line, end_line, sortline)
end, {
    range = true,
    nargs = '?',
    desc = 'Sort closed folds in the selected range',
})

-- Create visual mode mapping
vim.keymap.set(
    'v',
    '<Plug>SortFolds',
    function() vim.cmd("'<,'>SortFolds") end,
    { silent = true, desc = 'Sort folds in visual selection' }
)

-- Set default mapping if not already mapped
if vim.fn.hasmapto('<Plug>SortFolds', 'v') == 0 then
    vim.keymap.set('v', '<leader>sf', '<Plug>SortFolds', { silent = true, desc = 'Sort folds' })
end
