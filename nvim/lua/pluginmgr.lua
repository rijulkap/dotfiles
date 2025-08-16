local M = {}

local normal_loaded_plugins_spec = {}
local normal_loaded_plugins_setup = {}
local lazy_loaded_plugins_spec = {}

---@param spec vim.pack.Spec
function M.add_normal_spec(spec )
    table.insert(normal_loaded_plugins_spec, spec)
end

function M.add_normal_setup(setup_func)
    table.insert(normal_loaded_plugins_setup, setup_func)
end

---@param spec vim.pack.Spec
function M.add_lazy_spec(spec)
    table.insert(lazy_loaded_plugins_spec, spec)
end

function M.install_all()
    vim.pack.add(normal_loaded_plugins_spec, { confirm = false, load = true })
    vim.pack.add(lazy_loaded_plugins_spec, { confirm = false, load = function() end })
end

function M.setup_normal()
    for _, setup in ipairs(normal_loaded_plugins_setup) do
        setup()
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
