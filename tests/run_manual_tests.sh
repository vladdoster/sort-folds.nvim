#!/usr/bin/env bash
# Simple manual test runner that doesn't require external dependencies
# This creates temporary test files and runs them with nvim in headless mode
#
# NOTE: For better formatted tests, use: nvim --headless -l tests/manual_test.lua

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "${SCRIPT_DIR}")"

echo "Running manual unit tests for sort-folds..."

# Find nvim
if ! command -v nvim &> /dev/null; then
    echo "Error: nvim not found"
    exit 1
fi

echo "Using nvim"

# Test 1: Basic alphabetical sorting
echo "Test 1: Basic alphabetical sorting..."
cat > /tmp/test1_input.txt << 'EOF'
{{{ Fold C
Content C
}}}
{{{ Fold A
Content A
}}}
{{{ Fold B
Content B
}}}
EOF

nvim --headless -u NONE -i NONE \
  -c "set runtimepath^=${PLUGIN_DIR}" \
  -c "e /tmp/test1_input.txt" \
  -c "set foldmethod=marker" \
  -c "normal! gg" \
  -c "normal! zc" \
  -c "normal! 4G" \
  -c "normal! zc" \
  -c "normal! 7G" \
  -c "normal! zc" \
  -c "%call SortFolds#SortFolds()" \
  -c "w /tmp/test1_output.txt" \
  -c "q" 2>&1 | grep -v "^$" || true

# Check result
if head -n 1 /tmp/test1_output.txt | grep -q "{{{ Fold A"; then
    echo "✓ Test 1 passed: Folds sorted alphabetically"
else
    echo "✗ Test 1 failed"
    echo "Expected first line: {{{ Fold A"
    echo "Actual output:"
    cat /tmp/test1_output.txt
    exit 1
fi

# Test 2: Custom key function with numeric sorting
echo "Test 2: Custom key function with numeric sorting..."
cat > /tmp/test2_input.txt << 'EOF'
{{{ Item
priority: 3
}}}
{{{ Item
priority: 1
}}}
{{{ Item
priority: 2
}}}
EOF

nvim --headless -u NONE -i NONE \
  -c "set runtimepath^=${PLUGIN_DIR}" \
  -c "e /tmp/test2_input.txt" \
  -c "set foldmethod=marker" \
  -c "normal! gg" \
  -c "normal! zc" \
  -c "normal! 4G" \
  -c "normal! zc" \
  -c "normal! 7G" \
  -c "normal! zc" \
  -c "lua require('sort-folds').register_key_function('priority_sort', function(fold) local line = fold:get_line(1) or ''; local match = line:match('priority:%s*(%d+)'); return tonumber(match) or 0 end)" \
  -c "let g:sort_folds_key_function='priority_sort'" \
  -c "%call SortFolds#SortFolds()" \
  -c "w /tmp/test2_output.txt" \
  -c "q" 2>&1 | grep -v "^$" || true

# Check result - priority: 1 should be first (line 2)
if sed -n '2p' /tmp/test2_output.txt | grep -q "priority: 1"; then
    echo "✓ Test 2 passed: Custom key function sorts numerically"
else
    echo "✗ Test 2 failed"
    echo "Expected line 2: priority: 1"
    echo "Actual output:"
    cat /tmp/test2_output.txt
    exit 1
fi

# Test 3: Case-insensitive sorting
echo "Test 3: Case-insensitive sorting..."
cat > /tmp/test3_input.txt << 'EOF'
{{{ fold c
Content C
}}}
{{{ Fold A
Content A
}}}
{{{ FOLD B
Content B
}}}
EOF

nvim --headless -u NONE -i NONE \
  -c "set runtimepath^=${PLUGIN_DIR}" \
  -c "e /tmp/test3_input.txt" \
  -c "set foldmethod=marker" \
  -c "let g:sort_folds_ignore_case=1" \
  -c "normal! gg" \
  -c "normal! zc" \
  -c "normal! 4G" \
  -c "normal! zc" \
  -c "normal! 7G" \
  -c "normal! zc" \
  -c "%call SortFolds#SortFolds()" \
  -c "w /tmp/test3_output.txt" \
  -c "q" 2>&1 | grep -v "^$" || true

# Check result - should be case-insensitive (Fold A first)
if head -n 1 /tmp/test3_output.txt | grep -q "{{{ Fold A"; then
    echo "✓ Test 3 passed: Case-insensitive sorting works"
else
    echo "✗ Test 3 failed"
    echo "Expected first line: {{{ Fold A"
    echo "Actual output:"
    cat /tmp/test3_output.txt
    exit 1
fi

# Test 4: Built-in get_citekey function
echo "Test 4: Built-in get_citekey function..."
cat > /tmp/test4_input.txt << 'EOF'
{{{ @article{smith2020,
  author = {Smith}
}}}
{{{ @book{jones2019,
  author = {Jones}
}}}
{{{ @inproceedings{adams2021,
  author = {Adams}
}}}
EOF

nvim --headless -u NONE -i NONE \
  -c "set runtimepath^=${PLUGIN_DIR}" \
  -c "e /tmp/test4_input.txt" \
  -c "set foldmethod=marker" \
  -c "normal! gg" \
  -c "normal! zc" \
  -c "normal! 4G" \
  -c "normal! zc" \
  -c "normal! 7G" \
  -c "normal! zc" \
  -c "let g:sort_folds_key_function='get_citekey'" \
  -c "%call SortFolds#SortFolds()" \
  -c "w /tmp/test4_output.txt" \
  -c "q" 2>&1 | grep -v "^$" || true

# Check result - adams2021 should be first
if head -n 1 /tmp/test4_output.txt | grep -q "adams2021"; then
    echo "✓ Test 4 passed: Built-in get_citekey function works"
else
    echo "✗ Test 4 failed"
    echo "Expected first line to contain: adams2021"
    echo "Actual output:"
    cat /tmp/test4_output.txt
    exit 1
fi

echo ""
echo "All tests passed! ✓"
echo ""
echo "Tests verified:"
echo "  - Basic alphabetical fold sorting"
echo "  - Custom key functions with numeric sorting"
echo "  - Case-insensitive sorting"
echo "  - Built-in get_citekey function"

