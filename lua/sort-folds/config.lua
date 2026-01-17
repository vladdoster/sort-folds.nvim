-- config.lua - Configuration handling for sort-folds
-- License: MIT license

local key_functions = require('sort-folds.key_functions')

local M = {}

-- Get the key function for sorting folds by a specific line
-- @param sort_line: Line index to sort by (0-indexed within each fold)
function M.get_fold_to_sort_key(sort_line)
  local ignore_case = vim.g.sort_folds_ignore_case or 0
  
  if ignore_case == 0 then
    return function(fold)
      return fold:get_line(sort_line) or ""
    end
  else
    return function(fold)
      local line = fold:get_line(sort_line) or ""
      return line:lower()
    end
  end
end

-- Get custom key function if defined
function M.get_key_function()
  if vim.g.sort_folds_key_function then
    local function_name = vim.g.sort_folds_key_function
    local func = key_functions.get(function_name)
    if not func then
      error("Could not find custom key-function: " .. function_name)
    end
    return func
  end
  return nil
end

return M
