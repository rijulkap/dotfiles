local M = {}

local normal_loaded_plugins_spec = {}
local normal_loaded_plugins_setup = {}
local lazy_loaded_plugins_spec = {}

---@param spec vim.pack.Spec
function M.add_normal(spec, setup_func)
    table.insert(normal_loaded_plugins_spec, spec)
    table.insert(normal_loaded_plugins_setup, setup_func)
end

---@param spec vim.pack.Spec
function M.add_lazy(spec)
    table.insert(lazy_loaded_plugins_spec, spec)
    -- table.insert(lazy_loaded_plugins_setup, setup_func)
end

function M.install_all()
    vim.pack.add(normal_loaded_plugins_spec, { confirm = false, load = true })
    vim.pack.add(lazy_loaded_plugins_spec, { confirm = false, load = function() end })
end

function M.setup_normal()
    for _, p in ipairs(normal_loaded_plugins_setup) do
    	if p ~= nil then
            p()
        end
    end
end

local gr = vim.api.nvim_create_augroup("pack-add", {})

M.pack_setup_on_event = function(event, name, setup)
    local cb = function()
        vim.cmd.packadd(name)
        setup()
    end
    vim.api.nvim_create_autocmd(event, { group = gr, callback = cb, once = true })
end

return M
