" SortFolds.vim - Sort closed folds based on first line
" Maintainer:   Oliver Breitwieser
" Version:      1.2.0
" License:      MIT license

function! SortFolds#SortFolds(...) range
    let sortline = get(a:, 0, 0)
    lua require('sort-folds').sort_folds(vim.fn.eval('sortline'))
endfunction
