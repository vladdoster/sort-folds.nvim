-- Helper script for Busted to set up Neovim environment
-- This loads after busted's environment is set up

-- Set up plugin path for tests
local function setup_plugin_path()
  local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h")
  vim.o.runtimepath = plugin_dir .. "," .. vim.o.runtimepath
end

-- Call setup
setup_plugin_path()
