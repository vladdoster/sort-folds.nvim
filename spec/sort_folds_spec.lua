-- Unit tests for sort-folds plugin using Busted framework
-- Run with: busted spec/

describe('sort-folds', function()
    local sort_folds

    -- Set up before all tests
    setup(function() sort_folds = require('sort-folds') end)

    -- Set up a test buffer before each test
    before_each(function()
        vim.cmd('enew!')
        vim.cmd('setlocal foldmethod=marker')
    end)

    -- Clean up after each test
    after_each(function() vim.cmd('bwipeout!') end)

    describe('fold.lua', function()
        it('should create a fold object with correct properties', function()
            local fold_module = require('sort-folds.fold')
            local lines = {
                '{{{ Fold A',
                'Content A',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            local folds = fold_module.get_folds(1, 3)
            assert.is_not_nil(folds)
            assert.equals(1, #folds)

            local Fold = getmetatable(folds[1])
            assert.is_not_nil(Fold)
        end)

        it('should get correct line from fold', function()
            local fold_module = require('sort-folds.fold')
            local lines = {
                '{{{ Fold A',
                'Line 1',
                'Line 2',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.cmd('normal! zc')

            local folds = fold_module.get_folds(1, 4)
            assert.equals(1, #folds)
            assert.equals('{{{ Fold A', folds[1]:get_line(0))
            assert.equals('Line 1', folds[1]:get_line(1))
            assert.equals('Line 2', folds[1]:get_line(2))
        end)

        it('should detect multiple folds', function()
            local fold_module = require('sort-folds.fold')
            local lines = {
                '{{{ Fold A',
                'Content A',
                '}}}',
                '{{{ Fold B',
                'Content B',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! j')
            vim.cmd('normal! zc')

            local folds = fold_module.get_folds(1, 6)
            assert.equals(2, #folds)
        end)
    end)

    describe('basic sorting', function()
        it('should sort folds alphabetically', function()
            local lines = {
                '{{{ Fold C',
                'Content C',
                '}}}',
                '{{{ Fold A',
                'Content A',
                '}}}',
                '{{{ Fold B',
                'Content B',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            -- Close all folds
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! 4G')
            vim.cmd('normal! zc')
            vim.cmd('normal! 7G')
            vim.cmd('normal! zc')

            -- Sort folds
            sort_folds.sort_folds_range(1, 9, 0)

            -- Check results
            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.equals('{{{ Fold A', result[1])
            assert.equals('{{{ Fold B', result[4])
            assert.equals('{{{ Fold C', result[7])
        end)

        it('should sort folds case-insensitively when configured', function()
            vim.g.sort_folds_ignore_case = 1

            local lines = {
                '{{{ fold c',
                'Content C',
                '}}}',
                '{{{ Fold A',
                'Content A',
                '}}}',
                '{{{ FOLD B',
                'Content B',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            -- Close all folds
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! 4G')
            vim.cmd('normal! zc')
            vim.cmd('normal! 7G')
            vim.cmd('normal! zc')

            -- Sort folds
            sort_folds.sort_folds_range(1, 9, 0)

            -- Check results (case-insensitive sort)
            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.equals('{{{ Fold A', result[1])
            assert.equals('{{{ FOLD B', result[4])
            assert.equals('{{{ fold c', result[7])

            -- Reset
            vim.g.sort_folds_ignore_case = 0
        end)
    end)

    describe('custom key functions', function()
        it('should sort by custom numeric key', function()
            local lines = {
                '{{{ Item',
                'priority: 3',
                '}}}',
                '{{{ Item',
                'priority: 1',
                '}}}',
                '{{{ Item',
                'priority: 2',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            -- Close all folds
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! 4G')
            vim.cmd('normal! zc')
            vim.cmd('normal! 7G')
            vim.cmd('normal! zc')

            -- Register custom key function
            sort_folds.register_key_function('priority_sort', function(fold)
                local line = fold:get_line(1) or ''
                local match = line:match('priority:%s*(%d+)')
                return tonumber(match) or 0
            end)

            vim.g.sort_folds_key_function = 'priority_sort'

            -- Sort folds
            sort_folds.sort_folds_range(1, 9, 0)

            -- Check results
            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.equals('priority: 1', result[2])
            assert.equals('priority: 2', result[5])
            assert.equals('priority: 3', result[8])

            -- Reset
            vim.g.sort_folds_key_function = nil
        end)

        it('should use built-in get_citekey function', function()
            local lines = {
                '{{{ @article{smith2020,',
                '  author = {Smith}',
                '}}}',
                '{{{ @book{jones2019,',
                '  author = {Jones}',
                '}}}',
                '{{{ @inproceedings{adams2021,',
                '  author = {Adams}',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            -- Close all folds
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! 4G')
            vim.cmd('normal! zc')
            vim.cmd('normal! 7G')
            vim.cmd('normal! zc')

            vim.g.sort_folds_key_function = 'get_citekey'

            -- Sort folds
            sort_folds.sort_folds_range(1, 9, 0)

            -- Check results (sorted by citekey)
            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.is_truthy(result[1]:match('adams2021'))
            assert.is_truthy(result[4]:match('jones2019'))
            assert.is_truthy(result[7]:match('smith2020'))

            -- Reset
            vim.g.sort_folds_key_function = nil
        end)
    end)

    describe('edge cases', function()
        it('should handle single fold', function()
            local lines = {
                '{{{ Only Fold',
                'Content',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')

            -- Should not error
            sort_folds.sort_folds_range(1, 3, 0)

            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.equals('{{{ Only Fold', result[1])
        end)

        it('should handle empty buffer', function()
            -- Should not error on empty buffer
            local ok = pcall(function() sort_folds.sort_folds_range(1, 1, 0) end)
            assert.is_true(ok)
        end)

        it('should handle nested folds at same level', function()
            local lines = {
                '{{{ Fold Z',
                'Content Z',
                '}}}',
                '{{{ Fold A',
                'Content A',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')
            vim.cmd('normal! 4G')
            vim.cmd('normal! zc')

            sort_folds.sort_folds_range(1, 6, 0)

            local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            assert.equals('{{{ Fold A', result[1])
            assert.equals('{{{ Fold Z', result[4])
        end)
    end)

    describe('config', function()
        it('should respect sort_folds_ignore_case setting', function()
            local config = require('sort-folds.config')
            local fold_module = require('sort-folds.fold')

            -- Create a test buffer with a fold
            local lines = {
                '{{{ ABC',
                'Content',
                '}}}',
            }
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            vim.cmd('normal! gg')
            vim.cmd('normal! zc')

            -- Get actual fold object
            local folds = fold_module.get_folds(1, 3)
            assert.equals(1, #folds)
            local test_fold = folds[1]

            -- Test case-sensitive
            vim.g.sort_folds_ignore_case = 0
            local key_fn = config.get_fold_to_sort_key(0)
            assert.equals('{{{ ABC', key_fn(test_fold))

            -- Test case-insensitive
            vim.g.sort_folds_ignore_case = 1
            key_fn = config.get_fold_to_sort_key(0)
            assert.equals('{{{ abc', key_fn(test_fold))

            -- Reset
            vim.g.sort_folds_ignore_case = 0
        end)
    end)
end)
