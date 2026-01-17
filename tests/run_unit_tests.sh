#!/usr/bin/env bash
# Run unit tests using plenary.nvim test framework
#
# Usage:
#   ./tests/run_unit_tests.sh

set -e

# Check if plenary.nvim is installed
if [ ! -d "${HOME}/.local/share/nvim/site/pack/vendor/start/plenary.nvim" ]; then
  echo "Installing plenary.nvim for testing..."
  mkdir -p "${HOME}/.local/share/nvim/site/pack/vendor/start"
  git clone --depth=1 https://github.com/nvim-lua/plenary.nvim.git \
    "${HOME}/.local/share/nvim/site/pack/vendor/start/plenary.nvim"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "${SCRIPT_DIR}")"

# Run the tests
nvim --headless --noplugin \
  -u NONE \
  -c "set runtimepath^=${PLUGIN_DIR}" \
  -c "set runtimepath^=${HOME}/.local/share/nvim/site/pack/vendor/start/plenary.nvim" \
  -c "runtime plugin/plenary.vim" \
  -c "PlenaryBustedDirectory ${SCRIPT_DIR}/ { minimal_init = '${SCRIPT_DIR}/minimal_init.vim' }"
