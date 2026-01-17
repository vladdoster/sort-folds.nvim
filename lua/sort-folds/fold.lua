-- fold.lua - Fold handling for sort-folds
-- License: MIT license

local utils = require('sort-folds.utils')

local M = {}

-- Fold object
local Fold = {}
Fold.__index = Fold

-- Create a new Fold object
-- @param start: starting line (1-indexed)
-- @param end_line: first line after the fold (1-indexed, exclusive)
-- @param buffer: buffer handle (optional, defaults to current buffer)
function Fold.new(start, end_line, buffer)
    buffer = buffer or vim.api.nvim_get_current_buf()

    local self = setmetatable({}, Fold)
    self.start = start
    self.end_line = end_line
    self.buffer = buffer
    self._level = M.get_foldlevel_at(start)

    return self
end

-- Get the length of the fold
function Fold:len() return self.end_line - self.start end

-- Get a line from the fold (0-indexed within the fold)
function Fold:get_line(idx)
    local line_num = self.start + idx
    if line_num >= self.end_line then return nil end
    return vim.api.nvim_buf_get_lines(self.buffer, line_num - 1, line_num, false)[1]
end

-- Get all lines from the fold
function Fold:get_lines() return vim.api.nvim_buf_get_lines(self.buffer, self.start - 1, self.end_line - 1, false) end

-- Iterator over fold lines
function Fold:iter()
    local lines = self:get_lines()
    local i = 0
    return function()
        i = i + 1
        return lines[i]
    end
end

-- String representation (first line)
function Fold:__tostring() return self:get_line(0) or '' end

-- Get foldlevel at a given line number
function M.get_foldlevel_at(lineno) return vim.fn.foldlevel(lineno) end

-- Get all folds in the specified range
-- @param start_line: Starting line (1-indexed, inclusive)
-- @param end_line: Ending line (1-indexed, inclusive)
function M.get_folds(start_line, end_line)
    return utils.preserve_cursor(function()
        local folds = {}
        local fold_start = start_line
        local fold_end = -1

        -- Move to starting line
        vim.api.nvim_win_set_cursor(0, { start_line, 0 })

        local function move_to_next_fold()
            utils.normal('zj')
            return vim.fn.line('.')
        end

        while fold_end < end_line do
            fold_end = math.min(move_to_next_fold(), end_line)

            if fold_end < fold_start then
                -- We are iterating on the last fold, which is closed, therefore we
                -- seem to jump back in lines -> we are done
                break
            end

            if fold_end == fold_start then
                -- If we ran out of folds, just put everything till the end in a
                -- pseudo fold
                fold_end = end_line
            end

            if fold_end == end_line then
                -- adjust for having reached the end
                fold_end = fold_end + 1
            end

            local fold = Fold.new(fold_start, fold_end)

            if fold:len() > 0 then table.insert(folds, fold) end

            fold_start = fold_end
        end

        return folds
    end)
end

return M
