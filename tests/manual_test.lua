-- Manual test script for sort-folds
-- Run with: nvim --headless -l tests/manual_test.lua

-- Set up plugin path
local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h")
vim.o.runtimepath = plugin_dir .. "," .. vim.o.runtimepath

local sort_folds = require('sort-folds')

local function test_basic_sorting()
  print("Test 1: Basic alphabetical sorting...")
  
  -- Create test buffer
  vim.cmd('enew!')
  local lines = {
    "{{{ Fold C",
    "Content C",
    "}}}",
    "{{{ Fold A",
    "Content A",
    "}}}",
    "{{{ Fold B",
    "Content B",
    "}}}"
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd('set foldmethod=marker')
  
  -- Close all folds
  vim.cmd('normal! gg')
  vim.cmd('normal! zc')
  vim.cmd('normal! 4G')
  vim.cmd('normal! zc')
  vim.cmd('normal! 7G')
  vim.cmd('normal! zc')
  
  -- Sort
  sort_folds.sort_folds_range(1, 9, 0)
  
  -- Check result
  local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if result[1] == "{{{ Fold A" and result[4] == "{{{ Fold B" and result[7] == "{{{ Fold C" then
    print("✓ Test 1 passed: Folds sorted alphabetically")
    return true
  else
    print("✗ Test 1 failed")
    print("Expected: {{{ Fold A, {{{ Fold B, {{{ Fold C")
    print("Got: " .. result[1] .. ", " .. result[4] .. ", " .. result[7])
    return false
  end
end

local function test_custom_key()
  print("Test 2: Custom key function with numeric sorting...")
  
  vim.cmd('enew!')
  local lines = {
    "{{{ Item",
    "priority: 3",
    "}}}",
    "{{{ Item",
    "priority: 1",
    "}}}",
    "{{{ Item",
    "priority: 2",
    "}}}"
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd('set foldmethod=marker')
  
  vim.cmd('normal! gg')
  vim.cmd('normal! zc')
  vim.cmd('normal! 4G')
  vim.cmd('normal! zc')
  vim.cmd('normal! 7G')
  vim.cmd('normal! zc')
  
  -- Register custom key function
  sort_folds.register_key_function('priority_sort', function(fold)
    local line = fold:get_line(1) or ""
    local match = line:match("priority:%s*(%d+)")
    return tonumber(match) or 0
  end)
  
  vim.g.sort_folds_key_function = 'priority_sort'
  sort_folds.sort_folds_range(1, 9, 0)
  
  local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if result[2] == "priority: 1" and result[5] == "priority: 2" and result[8] == "priority: 3" then
    print("✓ Test 2 passed: Custom key function sorts numerically")
    vim.g.sort_folds_key_function = nil
    return true
  else
    print("✗ Test 2 failed")
    print("Expected priorities: 1, 2, 3")
    print("Got: " .. result[2] .. ", " .. result[5] .. ", " .. result[8])
    vim.g.sort_folds_key_function = nil
    return false
  end
end

local function test_case_insensitive()
  print("Test 3: Case-insensitive sorting...")
  
  vim.cmd('enew!')
  local lines = {
    "{{{ fold c",
    "Content C",
    "}}}",
    "{{{ Fold A",
    "Content A",
    "}}}",
    "{{{ FOLD B",
    "Content B",
    "}}}"
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd('set foldmethod=marker')
  
  vim.g.sort_folds_ignore_case = 1
  
  vim.cmd('normal! gg')
  vim.cmd('normal! zc')
  vim.cmd('normal! 4G')
  vim.cmd('normal! zc')
  vim.cmd('normal! 7G')
  vim.cmd('normal! zc')
  
  sort_folds.sort_folds_range(1, 9, 0)
  
  local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Case-insensitive: should be A, B, c
  if result[1] == "{{{ Fold A" and result[4] == "{{{ FOLD B" and result[7] == "{{{ fold c" then
    print("✓ Test 3 passed: Case-insensitive sorting works")
    vim.g.sort_folds_ignore_case = 0
    return true
  else
    print("✗ Test 3 failed")
    print("Expected (case-insensitive): Fold A, FOLD B, fold c")
    print("Got: " .. result[1] .. ", " .. result[4] .. ", " .. result[7])
    vim.g.sort_folds_ignore_case = 0
    return false
  end
end

local function test_get_citekey()
  print("Test 4: Built-in get_citekey function...")
  
  vim.cmd('enew!')
  local lines = {
    "{{{ @article{smith2020,",
    "  author = {Smith}",
    "}}}",
    "{{{ @book{jones2019,",
    "  author = {Jones}",
    "}}}",
    "{{{ @inproceedings{adams2021,",
    "  author = {Adams}",
    "}}}"
  }
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd('set foldmethod=marker')
  
  vim.cmd('normal! gg')
  vim.cmd('normal! zc')
  vim.cmd('normal! 4G')
  vim.cmd('normal! zc')
  vim.cmd('normal! 7G')
  vim.cmd('normal! zc')
  
  vim.g.sort_folds_key_function = 'get_citekey'
  sort_folds.sort_folds_range(1, 9, 0)
  
  local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Should be sorted by citekey: adams2021, jones2019, smith2020
  if result[1]:match("adams2021") and result[4]:match("jones2019") and result[7]:match("smith2020") then
    print("✓ Test 4 passed: Built-in get_citekey function works")
    vim.g.sort_folds_key_function = nil
    return true
  else
    print("✗ Test 4 failed")
    print("Expected order: adams2021, jones2019, smith2020")
    print("Got: " .. result[1] .. ", " .. result[4] .. ", " .. result[7])
    vim.g.sort_folds_key_function = nil
    return false
  end
end

-- Run all tests
print("Running manual unit tests for sort-folds...")
print("")

local all_passed = true
all_passed = test_basic_sorting() and all_passed
all_passed = test_custom_key() and all_passed
all_passed = test_case_insensitive() and all_passed
all_passed = test_get_citekey() and all_passed

print("")
if all_passed then
  print("All tests passed! ✓")
  print("")
  print("Tests verified:")
  print("  - Basic alphabetical fold sorting")
  print("  - Custom key functions with numeric sorting")
  print("  - Case-insensitive sorting")
  print("  - Built-in get_citekey function")
  os.exit(0)
else
  print("Some tests failed ✗")
  os.exit(1)
end
