local utils = require("utils")
local function disable_hover(client)
    if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
    end
end
utils.dyn_lsp_methods:add(disable_hover)
return {}
