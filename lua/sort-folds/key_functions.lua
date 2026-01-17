-- key_functions.lua - Custom key functions for sorting
-- License: MIT license

local M = {}

-- Registry of custom key functions
local registered_functions = {}

-- Register a key function
-- @param name: Name of the function
-- @param func: Function to register
function M.register(name, func)
  registered_functions[name] = func
end

-- Get a registered key function by name
-- @param name: Name of the function to retrieve
function M.get(name)
  return registered_functions[name]
end

-- Built-in: Extract BibTeX citation key
local function get_citekey(fold)
  local first_line = fold:get_line(0) or ""
  -- Skip fold markers and extract the citekey after the entry type
  -- Pattern matches: @type{citekey, or @type{citekey}
  -- [^,}]+ matches characters until comma or closing brace
  local citekey = first_line:match("@%w+{([^,}]+)")
  return citekey or ""
end

-- Register built-in functions
M.register("get_citekey", get_citekey)

return M
