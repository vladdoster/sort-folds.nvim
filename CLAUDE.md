# CLAUDE.md - Repository Guide for AI Assistants

## Repository Overview

**sort-folds.nvim** is a Neovim/Vim plugin that enables sorting of folded regions while keeping the folds intact. This is particularly useful for organizing functions, classes, BibTeX entries, or any foldable text blocks alphabetically or by custom criteria.

**Current Version:** 1.3.1
**License:** MIT
**Language:** Lua (migrated from Python in earlier versions)
**Requirements:** Neovim 0.5.0+ or Vim 8.2+ with Lua support

## Key Features

- Sort visually selected regions containing closed folds
- Preserve fold structure during sorting
- Case-sensitive or case-insensitive sorting
- Custom key functions for specialized sorting logic
- Built-in support for BibTeX citation key sorting
- Simple visual mode mapping (`<leader>sf` by default)

## Architecture

### Module Structure

The plugin follows a modular Lua architecture:

```
lua/sort-folds/
├── init.lua           # Main entry point, exports public API
├── config.lua         # Configuration handling, version info
├── fold.lua           # Fold object and fold detection logic
├── sort.lua           # Core sorting algorithms
├── key_functions.lua  # Custom key function registry
└── utils.lua          # Utility functions (cursor preservation, normal mode)

plugin/
└── sort-folds.lua     # Plugin initialization, commands, mappings

spec/
├── sort_folds_spec.lua  # Test suite
└── helper.lua           # Test helpers
```

### Core Components

#### 1. Fold Object (`fold.lua`)
- **Fold class**: Represents a single fold with start/end line boundaries
- Key methods:
  - `Fold.new(start, end_line, buffer)`: Constructor
  - `get_line(idx)`: Get line at index (0-based within fold)
  - `get_lines()`: Get all lines in fold
  - `len()`: Fold length
- **get_folds(start_line, end_line)**: Detects all folds in a range by navigating with `zj` (next fold)

#### 2. Sorting Logic (`sort.lua`)
- **sort_folds_range(start_line, end_line, sort_line)**: Main sorting function
  - Gets key function (custom or default)
  - Extracts all folds in range
  - Sorts folds by their keys
  - Replaces buffer range with sorted content
- **sort_folds(sort_line)**: Convenience wrapper using visual selection marks

#### 3. Configuration (`config.lua`)
- **version**: Tracked by release-please automation
- **get_fold_to_sort_key(sort_line)**: Creates default key function
  - Respects `g:sort_folds_ignore_case` setting
  - Returns line at `sort_line` index (0-based)
- **get_key_function()**: Retrieves custom key function if `g:sort_folds_key_function` is set

#### 4. Custom Key Functions (`key_functions.lua`)
- Registry system for named key functions
- Built-in `get_citekey`: Extracts BibTeX citation keys using pattern `@%w+{([^,}]+)`
- Users can register custom functions via `require('sort-folds').register_key_function(name, func)`

#### 5. Plugin Initialization (`plugin/sort-folds.lua`)
- Creates `:SortFolds [sortline]` command (range-aware)
- Defines `<Plug>SortFolds` mapping
- Sets default `<leader>sf` mapping if not already mapped
- Initializes `g:sort_folds_ignore_case` to 0

## Configuration

### Modern Lua Setup

```lua
require('sort-folds').setup({
  ignore_case = false,       -- Case-insensitive sorting
  key_function = 'get_citekey'  -- Use custom key function
})
```

### Legacy VimScript

```vim
let g:sort_folds_ignore_case = 1
let g:sort_folds_key_function = 'get_citekey'
```

### Custom Key Functions

Users define custom sorting logic by registering key functions:

```lua
local sort_folds = require('sort-folds')
sort_folds.register_key_function('custom_sort', function(fold)
  local line = fold:get_line(0) or ""
  return line:match("pattern") or ""
end)
```

## Testing

- **Framework:** Busted with vusted (Neovim test runner)
- **Location:** `spec/sort_folds_spec.lua`
- **Run tests:** `make test`
- **Coverage:** `make test-coverage`

Test coverage includes:
- Fold detection and object creation
- Basic alphabetical sorting
- Case-insensitive sorting
- Custom key functions
- Edge cases (single fold, empty buffer, nested folds)

## Development Workflow

### Building/Testing
```bash
make install        # Install test dependencies (busted, vusted, luacov)
make test          # Run test suite
make test-coverage # Generate coverage report
make clean         # Remove temporary files
```

### Key Conventions
- **Line numbering:** 1-indexed for buffer lines, 0-indexed for fold-relative access
- **Fold detection:** Uses `zj` (next fold) motion and `foldlevel()` function
- **Cursor preservation:** All operations preserve cursor position via `utils.preserve_cursor()`
- **Error handling:** Custom key functions should return empty string on failure

### Git Workflow
- **Main branch:** Release-please manages versioning automatically
- **Version updates:** Edit `config.lua` version string between `x-release-please-start-version` markers
- **Commit format:** Follows Conventional Commits (feat:, fix:, docs:, etc.)

## Common Tasks

### Adding a New Built-in Key Function

1. Edit `lua/sort-folds/key_functions.lua`
2. Define the function:
   ```lua
   local function my_function(fold)
     local line = fold:get_line(0) or ''
     -- Extract sorting key
     return key or ''
   end
   ```
3. Register it: `M.register('my_function', my_function)`
4. Document in README.md

### Modifying Sorting Behavior

Edit `lua/sort-folds/sort.lua`:
- **sort_folds_range()**: Core sorting logic
- Uses Lua's `table.sort()` with custom comparator
- Keys are compared with `<` operator (works for strings and numbers)

### Changing Default Mappings

Edit `plugin/sort-folds.lua`:
- Modify `<leader>sf` default mapping
- Adjust `:SortFolds` command parameters

### Adding Configuration Options

1. Add option handling in `lua/sort-folds/init.lua` setup function
2. Store in `vim.g.sort_folds_*` global variable
3. Access in relevant module (usually `config.lua`)
4. Document in README.md

## Important Notes

### Fold Detection Algorithm
The plugin detects folds by:
1. Starting at the first line of the range
2. Using `zj` motion to jump to next fold start
3. Creating a Fold object for each detected region
4. Stopping when reaching or exceeding the end line

This approach handles:
- Closed folds (primary use case)
- Open regions (treated as pseudo-folds)
- Nested folds (sorted by top-level fold only)

### Limitations
- Only sorts by top-level folds; nested folds move with their parent
- Requires folds to be properly defined (via foldmethod)
- Sorting is in-place; no undo integration beyond Vim's normal undo

### Migration Notes
- **Pre-v1.3:** Plugin used Python 3
- **Post-v1.3:** Pure Lua implementation
- Old Python version available at `last-py3` tag
- Configuration maintains backward compatibility with VimScript globals

## File Locations

- **Documentation:** `doc/` (Vim help files)
- **Source code:** `lua/sort-folds/`
- **Tests:** `spec/`
- **Plugin entry:** `plugin/sort-folds.lua`
- **GitHub workflows:** `.github/workflows/`
- **Release config:** `.github/release-please-config.json`

## Dependencies

### Runtime
- Neovim 0.5.0+ or Vim 8.2+ with Lua support
- No external Lua dependencies

### Development
- LuaRocks (package manager)
- busted (test framework)
- vusted (Neovim test runner)
- luacov (coverage reporting)

## Support and Contributing

- **Original author:** Oliver Breitwieser (obreitwi)
- **Current maintainer:** Vlad Doster (vladdoster)
- **Repository:** https://github.com/vladdoster/sort-folds.nvim
- **Issues:** Report bugs and feature requests via GitHub issues
- **Testing:** All changes should include tests or update existing tests

## Quick Reference for AI Assistants

When working with this codebase:

1. **Reading files:** Use absolute paths starting with `/home/runner/work/sort-folds.nvim/sort-folds.nvim/`
2. **Testing changes:** Always run `make test` before committing
3. **Version updates:** Managed automatically by release-please; edit `config.lua` if needed
4. **Code style:** Follow existing Lua conventions (2-space indent, explicit returns)
5. **Documentation:** Update README.md for user-facing changes, TESTING.md for test changes
6. **Commit messages:** Use Conventional Commits format (feat:, fix:, docs:, test:, refactor:)
7. **Breaking changes:** Avoid breaking backward compatibility with VimScript configuration
8. **Key insight:** The plugin's core innovation is using `zj` motion to navigate folds for sorting
