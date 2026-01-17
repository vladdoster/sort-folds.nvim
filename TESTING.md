# Testing

This repository uses the [Busted](https://olivinelabs.com/busted/) Lua test framework for unit testing.

## Prerequisites

- Neovim 0.5.0+ or Vim 8.2+ with Lua support
- LuaRocks (Lua package manager)
- Busted test framework
- nlua (Neovim Lua interpreter)

## Quick Start

### Install Dependencies

```bash
make install
```

This will install `busted` and `nlua` using LuaRocks.

### Run Tests

```bash
make test
```

This runs all tests in the `spec/` directory using Busted.

### Other Makefile Targets

```bash
make help    # Display available targets
make clean   # Clean up temporary files
```

## Test Structure

Tests are located in the `spec/` directory:

- `spec/sort_folds_spec.lua` - Main test suite
- `spec/helper.lua` - Helper functions for test setup

## Test Coverage

The test suite verifies:

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

Busted uses a BDD-style syntax. Here's an example:

```lua
describe("feature name", function()
  -- Setup before each test
  before_each(function()
    vim.cmd('enew!')
    vim.cmd('setlocal foldmethod=marker')
  end)
  
  -- Cleanup after each test
  after_each(function()
    vim.cmd('bwipeout!')
  end)
  
  it("should do something", function()
    -- Test code
    local result = some_function()
    assert.equals(expected, result)
  end)
end)
```

### Available Assertions

Busted provides many assertion functions:

- `assert.equals(expected, actual)`
- `assert.is_true(value)`
- `assert.is_false(value)`
- `assert.is_nil(value)`
- `assert.is_not_nil(value)`
- `assert.is_truthy(value)`
- `assert.has_error(function)`

See [Busted documentation](https://olivinelabs.com/busted/) for more details.

## Manual Testing

For quick manual testing without the full framework:

```bash
nvim --headless -l tests/manual_test.lua
```

## Legacy Tests

The `tests/` directory contains legacy tests using Plenary.nvim. These are maintained for compatibility but new tests should be added to the `spec/` directory using Busted.

### Running Plenary Tests

```bash
cd tests
./run_unit_tests.sh
```
