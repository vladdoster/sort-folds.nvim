-- init.lua - Main entry point for sort-folds plugin
-- Maintainer:   Oliver Breitwieser
-- License:      MIT license

local M = {}

-- Re-export main modules
M.sort = require('sort-folds.sort')
M.fold = require('sort-folds.fold')
M.config = require('sort-folds.config')
M.key_functions = require('sort-folds.key_functions')

-- Main sorting function (convenience wrapper)
M.sort_folds = M.sort.sort_folds

-- Register a custom key function
function M.register_key_function(name, func)
  M.key_functions.register(name, func)
end

return M
