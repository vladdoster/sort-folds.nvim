-- sort.lua - Main sorting logic for sort-folds
-- License: MIT license

local fold = require('sort-folds.fold')
local config = require('sort-folds.config')

local M = {}

-- Sort folds in the current range
-- @param sort_line: Line by which to sort each fold (0-indexed within fold)
--                   Ignored if g:sort_folds_key_function is defined
function M.sort_folds(sort_line)
  sort_line = sort_line or 0
  
  -- Get the key function
  local key_function = config.get_key_function()
  if not key_function then
    key_function = config.get_fold_to_sort_key(sort_line)
  end
  
  -- Get all folds in the range
  local folds = fold.get_folds()
  
  -- Sort the folds
  table.sort(folds, function(a, b)
    local key_a = key_function(a)
    local key_b = key_function(b)
    return key_a < key_b
  end)
  
  -- Collect all sorted lines
  local sorted_lines = {}
  for _, f in ipairs(folds) do
    local lines = f:get_lines()
    for _, line in ipairs(lines) do
      table.insert(sorted_lines, line)
    end
  end
  
  -- Replace the range with sorted lines
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, sorted_lines)
end

return M
