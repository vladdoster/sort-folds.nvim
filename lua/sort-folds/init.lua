-- init.lua - Main entry point for sort-folds plugin
-- Maintainer:   Oliver Breitwieser
-- License:      MIT license

local M = {}

-- Re-export main modules
M.sort = require('sort-folds.sort')
M.fold = require('sort-folds.fold')
M.config = require('sort-folds.config')
M.key_functions = require('sort-folds.key_functions')

-- Main sorting functions
M.sort_folds = M.sort.sort_folds
M.sort_folds_range = M.sort.sort_folds_range

-- Register a custom key function
function M.register_key_function(name, func) M.key_functions.register(name, func) end

-- Setup function for configuring the plugin
-- @param opts table: Configuration options
--   - ignore_case: boolean - If true, sort case-insensitively (default: false)
--   - key_function: string - Name of a custom key function to use for sorting
function M.setup(opts)
    opts = opts or {}

    -- Set ignore_case option
    if opts.ignore_case ~= nil then vim.g.sort_folds_ignore_case = opts.ignore_case and 1 or 0 end

    -- Set custom key function
    if opts.key_function then vim.g.sort_folds_key_function = opts.key_function end
end

return M
