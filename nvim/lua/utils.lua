local utils = {}

-- Dyn LSP Methods Subtable
utils.dyn_lsp_methods = {
    __methods = {},
}

function utils.dyn_lsp_methods:add(method)
    table.insert(self.__methods, method)
end

function utils.dyn_lsp_methods:resolve(client, buf)
    for _, method in ipairs(self.__methods) do
        method(client, buf)
    end
end

return utils
