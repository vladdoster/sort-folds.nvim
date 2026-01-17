# SortFolds

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/obreitwi/vim-sort-folds/Run%20tests%20in%20vim)](https://github.com/obreitwi/vim-sort-folds/actions?query=workflow%3A%22Run+tests+in+vim%22)

## Overview

![](https://raw.github.com/obreitwi/vim-sort-folds/master/doc/demo.gif)  
_(Demo \w [SimpylFold](https://github.com/tmhedberg/SimpylFold),
colorscheme [xoria256](https://github.com/vim-scripts/xoria256.vim))_

Sorting folds is not easily possible in vanilla vim. You could join all lines
in a fold, sort and split them up again; however, it is time consuming and
tedious.

This little plugin solves that issue: It sorts a visually selected region while
keeping closed folds intact. Since folds can be created in a variety of ways,
it is therefore straight-forward to sort arbitrary groups of text based on
their first line.

One use-case (demonstrated above and the original motivation for this plugin)
is to sort functions alphabetically after the fact.

Furthermore, it is possible to sort based on other lines than then first.

## Requirements

* Neovim 0.5.0+ or Vim 8.2+ with Lua support

Note: This plugin now uses Lua instead of Python. For the old Python-based version, see the `last-py3` tag.

## Installation

`SortFolds` is compatible with most plugin managers for vim.
Just drop the following line in your `.vimrc`:

`Plugin 'obreitwi/vim-sort-folds'`
(for [Vundle](https://github.com/VundleVim/Vundle.vim))

`Plug 'obreitwi/vim-sort-folds'`
(for [vim-plug](https://github.com/junegunn/vim-plug))


## Mappings

Per default, sorting visually selected folds is mapped to `<leader>sf`, if
available, but can be easily remapped.


## Configuration

### Lua Configuration (Recommended)

You can configure the plugin using the `setup()` function:

```lua
require('sort-folds').setup({
  ignore_case = false,  -- Set to true for case-insensitive sorting (default: false)
})
```

### VimScript Configuration (Legacy)

You can also use VimScript global variables:

```vim
let g:sort_folds_ignore_case = 1
```
Default is `0`


## Custom key-function

Sometimes you need to sort folds by some custom key.
For this reason, you can define a custom sort function in Lua that maps fold
contents to a key (a string or number) by which the fold will be sorted.

### Example: Sort BibTeX-entries by key only, but not entry type

BibTeX-entries can be of several types (`article`, `book`, `inproceedings`,
`online`, to name a few…). However, we might want to sort them by citekey
regardless of type.

#### Using Lua Configuration

```lua
local sort_folds = require('sort-folds')

-- Register custom key function
sort_folds.register_key_function('get_citekey', function(fold)
  local first_line = fold:get_line(0) or ""
  local after_brace = first_line:match("{([^}]*)")
  if after_brace then
    local key = after_brace:match("([^,]*)")
    return key or ""
  end
  return ""
end)

-- Configure to use it
sort_folds.setup({
  key_function = 'get_citekey'
})
```

Or for a specific filetype:
```lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'bib',
  callback = function()
    vim.g.sort_folds_key_function = 'get_citekey'
  end
})
```

#### Using VimScript (Legacy)

```vim
lua <<EOF
local sort_folds = require('sort-folds')
sort_folds.register_key_function('get_citekey', function(fold)
  -- very crude extraction without regexes
  local first_line = fold:get_line(0) or ""
  local after_brace = first_line:match("{([^}]*)")
  if after_brace then
    local key = after_brace:match("([^,]*)")
    return key or ""
  end
  return ""
end)
EOF

autocmd FileType bib let g:sort_folds_key_function="get_citekey"
```

Note: `get_citekey` is already part of the builtin functions and can be used directly.
