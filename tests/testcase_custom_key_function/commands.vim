:set foldmethod=marker
:lua <<EOF
local sort_folds = require('sort-folds')
sort_folds.register_key_function('my_key_function', function(fold)
  local line = fold:get_line(1) or ""
  local match = line:match(":%s*(%d+)")
  return tonumber(match) or 0
end)
EOF
:let g:sort_folds_key_function="my_key_function"
:%call SortFolds#SortFolds()
:messages
:wq
