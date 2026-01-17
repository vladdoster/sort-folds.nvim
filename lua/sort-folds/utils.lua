-- utils.lua - Utility functions for sort-folds
-- License: MIT license

local M = {}

-- Execute a normal mode command
function M.normal(cmd)
  vim.cmd('normal! ' .. cmd)
end

-- Preserve cursor position during execution of a function
function M.preserve_cursor(func)
  local pos = vim.api.nvim_win_get_cursor(0)
  local ok, result = pcall(func)
  -- Only restore cursor if the position is valid
  local line_count = vim.api.nvim_buf_line_count(0)
  if pos[1] <= line_count then
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end
  if not ok then
    error(result)
  end
  return result
end

return M
