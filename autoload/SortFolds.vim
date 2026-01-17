" SortFolds.vim - Sort closed folds based on first line
" Maintainer:   Oliver Breitwieser
" Version:      1.2.0
" License:      MIT license

function! SortFolds#SortFolds(...) range
    let sortline = get(a:, 0, 0)
    lua << EOF
    local sortline = vim.fn.eval('sortline')
    local start_line = vim.fn.eval('a:firstline')
    local end_line = vim.fn.eval('a:lastline')
    require('sort-folds').sort_folds_range(start_line, end_line, sortline)
EOF
endfunction
