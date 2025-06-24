local utils = {}

local DynDispatch = {}
DynDispatch.__index = DynDispatch

function DynDispatch.new()
    return setmetatable({ __methods = {} }, DynDispatch)
end

function DynDispatch:add(fn)
    table.insert(self.__methods, fn)
end

function DynDispatch:resolve(client, buf)
    for _, m in ipairs(self.__methods) do
        if client ~= nil and buf ~= nil then
            m(client, buf)
        else
            m()
        end
    end
end

-- Dyn LSP Methods Subtable
utils.dyn_lsp_methods = DynDispatch.new()

-- Dyn esc handler
utils.dyn_exit = DynDispatch.new()

return utils
