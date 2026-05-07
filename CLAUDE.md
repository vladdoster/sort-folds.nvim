# CLAUDE.md

## Repository Overview

- **Project**: `sort-folds.nvim`
- **Type**: Neovim plugin (Lua)
- **Purpose**: Sorts visually selected folds while preserving fold boundaries/content.
- **Primary user command**: `:SortFolds [line]`
- **Primary mapping**: visual `<leader>sf` (via `<Plug>SortFolds`)

The plugin extracts folds in a selected range, computes a sortable key per fold, sorts folds, and replaces the original range with sorted fold contents.

---

## Runtime & Compatibility

- Requires **Neovim 0.5.0+**.
- Implemented fully in Lua.
- License: MIT.

---

## Repository Structure

- `/plugin/sort-folds.lua`
  - Plugin entrypoint loaded by runtimepath.
  - Defines `:SortFolds` user command.
  - Registers visual mapping `<Plug>SortFolds` and default `<leader>sf` when unbound.
  - Initializes default global setting `g:sort_folds_ignore_case`.

- `/lua/sort-folds/init.lua`
  - Public Lua API and setup surface.
  - Re-exports submodules and main functions.

- `/lua/sort-folds/sort.lua`
  - Core sorting workflow (`sort_folds_range`, `sort_folds`).

- `/lua/sort-folds/fold.lua`
  - Fold model and fold extraction logic from buffer range.

- `/lua/sort-folds/config.lua`
  - Configuration readers and key-function selection.

- `/lua/sort-folds/key_functions.lua`
  - Registry for custom key functions plus built-in `get_citekey`.

- `/lua/sort-folds/utils.lua`
  - Utility helpers (`normal`, `preserve_cursor`).

- `/doc/SortFolds.txt`
  - Vim help documentation.

- `/spec/sort_folds_spec.lua`, `/spec/helper.lua`
  - Busted/vusted test suite.

- `/Makefile`
  - Developer commands for test/dependency management.

- `/.github/workflows/test.yml`
  - CI test matrix (Neovim stable + nightly).

- `/.github/workflows/release.yml`
  - Release automation via release-please.

---

## Public API

From `require('sort-folds')`:

- `setup(opts)`
  - `ignore_case` (boolean): maps to `g:sort_folds_ignore_case` (0/1)
  - `key_function` (string): maps to `g:sort_folds_key_function`

- `sort_folds_range(start_line, end_line, sort_line?)`
  - Sorts folds in a given line range.

- `sort_folds(sort_line?)`
  - Backward-compatible wrapper using visual marks `'<` and `'>`.

- `register_key_function(name, func)`
  - Registers function in key-function registry.

Built-in key function:
- `get_citekey` (BibTeX citekey extraction)

---

## Core Sorting Flow

1. Determine sorting key function:
   - custom function from `g:sort_folds_key_function`, or
   - line-based function from `config.get_fold_to_sort_key(sort_line)`.
2. Build fold objects for selected range via `fold.get_folds(start_line, end_line)`.
3. Sort fold objects with `table.sort` by computed key.
4. Flatten sorted fold lines.
5. Replace original buffer range using `nvim_buf_set_lines`.

Important behavior notes:
- Sorting compares keys with `<`; keys should be mutually comparable (all strings or all numbers).
- Case handling is controlled by `g:sort_folds_ignore_case`.
- Fold extraction relies on normal-mode fold navigation (`zj`) and cursor preservation.

---

## Configuration Model

Global variables consumed at runtime:

- `g:sort_folds_ignore_case`
  - `0` (default) = case-sensitive
  - `1` = case-insensitive (line keys lowercased)

- `g:sort_folds_key_function`
  - Name of key function registered in `key_functions` registry.
  - If set to unknown name, plugin throws an error.

Recommended configuration path is Lua:

```lua
require('sort-folds').setup({
  ignore_case = false,
  key_function = nil,
})
```

---

## Command & Mapping UX

- Command:
  - `:'<,'>SortFolds`
  - `:'<,'>SortFolds 41` sorts by fold-local line index 41 (42nd line).

- Mapping:
  - `<Plug>SortFolds` in visual mode.
  - Default visual mapping `<leader>sf` only if no existing map to `<Plug>SortFolds`.

---

## Testing

Test framework stack:
- Busted
- vusted
- optional luacov coverage

Relevant files:
- `.busted` (test config)
- `spec/helper.lua` (runtimepath setup)
- `spec/sort_folds_spec.lua` (behavioral tests)

Make targets:
- `make help`
- `make test`
- `make test-coverage`
- `make install`
- `make clean`

Current environment caveat observed during analysis:
- `make test` fails if `vusted` is missing.
- `make install` requires `luarocks`; without it installation fails.

CI (`.github/workflows/test.yml`) installs LuaRocks + deps, then runs `make test-coverage` across Neovim stable/nightly.

---

## Release & Versioning

- Release automation uses `googleapis/release-please-action`.
- Version string is kept in `lua/sort-folds/config.lua` between:
  - `x-release-please-start-version`
  - `x-release-please-end`
- Release workflow currently triggers on pushes to `main`.

Branch naming issue to resolve:
- Test workflow is configured for `master`/`develop` (push) and PRs to `master`.
- Release workflow targets `main`.
- Repository maintainers should align workflow branch triggers with the intended default/release branch.

---

## Development Guidelines for Agents/Contributors

When changing behavior:

1. Keep changes localized to relevant module(s):
   - sorting behavior: `sort.lua`, `config.lua`, `key_functions.lua`
   - fold extraction behavior: `fold.lua`
   - command/mappings: `plugin/sort-folds.lua`
2. Preserve public API and command compatibility unless intentionally changing contract.
3. Update both user docs when needed:
   - `README.md`
   - `doc/SortFolds.txt`
4. Add/adjust tests in `spec/sort_folds_spec.lua` for behavior changes.
5. Prefer deterministic key functions and avoid mixed key types to prevent Lua comparison errors.

When adding key functions:
- Register via `register_key_function`.
- Ensure return values are sortable and stable.
- Handle missing/malformed lines defensively.

When editing fold logic:
- Preserve cursor safety via `utils.preserve_cursor`.
- Be careful with 1-indexed (editor-facing) vs 0-indexed (API/internal offsets) line arithmetic.

---

## Quick Reference Commands

```bash
# show available tasks
make help

# run tests (requires vusted)
make test

# install test dependencies (requires luarocks)
make install

# run tests with coverage report
make test-coverage
```

---

## Key Files to Read First

1. `plugin/sort-folds.lua`
2. `lua/sort-folds/sort.lua`
3. `lua/sort-folds/fold.lua`
4. `lua/sort-folds/config.lua`
5. `lua/sort-folds/key_functions.lua`
6. `spec/sort_folds_spec.lua`
7. `doc/SortFolds.txt`
