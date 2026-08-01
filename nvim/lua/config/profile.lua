local M = {}

local truthy = {
    ["1"] = true,
    ["true"] = true,
    ["yes"] = true,
    ["on"] = true,
}

local profile = (vim.env.NVIM_PROFILE or ""):lower()
local lite = profile == "lite" or truthy[(vim.env.NVIM_LITE or ""):lower()] == true

M.name = lite and "lite" or "full"

function M.is_lite()
    return lite
end

function M.has(feature)
    if not lite then
        return true
    end

    return feature ~= "lsp"
        and feature ~= "treesitter"
        and feature ~= "formatting"
        and feature ~= "debugging"
end

return M
