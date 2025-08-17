-- Get all files in lua/plugins/Extras/*.lua
local files = vim.api.nvim_get_runtime_file("lua/plugins/Extras/*.lua", true)

-- Exclude init.lua
files = vim.tbl_filter(function(path)
  return not path:match("init%.lua$")
end, files)

-- Require each file
for _, path in ipairs(files) do
  local filename = vim.fn.fnamemodify(path, ":t:r")
  require("plugins.Extras." .. filename)
end
