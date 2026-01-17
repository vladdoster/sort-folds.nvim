# Unit Tests

This directory contains unit tests for the sort-folds plugin.

## Running Tests

### Quick Test (No Dependencies)

Run the Lua-based manual tests with Neovim:

```bash
cd /path/to/sort-folds.nvim
nvim --headless -l tests/manual_test.lua
```

This will run all unit tests and verify:
- Basic alphabetical fold sorting
- Custom key functions with numeric sorting
- Case-insensitive sorting
- Built-in `get_citekey` function

### Plenary.nvim Tests (Full Framework)

For the full test suite with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim):

```bash
cd tests
./run_unit_tests.sh
```

The script will automatically install plenary.nvim if needed.

## Test Coverage

The unit tests verify:

1. **Fold Detection** (`fold.lua`)
   - Creating fold objects with correct properties
   - Getting lines from folds
   - Detecting multiple folds

2. **Basic Sorting**
   - Alphabetical sorting of folds
   - Case-insensitive sorting

3. **Custom Key Functions**
   - Sorting by custom numeric keys
   - Built-in `get_citekey` function for BibTeX entries

4. **Edge Cases**
   - Single fold
   - Empty buffer
   - Nested folds

5. **Configuration**
   - `sort_folds_ignore_case` setting

## Writing New Tests

### For manual_test.lua

Add a new test function:

```lua
local function test_my_feature()
  print("Test: My feature...")
  
  -- Setup
  vim.cmd('enew!')
  -- ... test code ...
  
  if condition then
    print("✓ Test passed")
    return true
  else
    print("✗ Test failed")
    return false
  end
end
```

Then add it to the test runner at the bottom of the file.

### For Plenary Tests (sort_folds_spec.lua)

Tests use the plenary.nvim test framework:

```lua
describe("feature name", function()
  before_each(function()
    -- Setup
  end)
  
  it("should do something", function()
    -- Test code
    assert.equals(expected, actual)
  end)
end)
```

