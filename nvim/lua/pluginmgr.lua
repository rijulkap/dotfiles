local M = {}

local plugins = {}

local group = vim.api.nvim_create_augroup("LazyPlugins", { clear = true })

---@param plugin vim.pack.Spec
function M.add_plugin(plugin)
    table.insert(plugins, plugin)
end

function M.install_all()
    vim.pack.add(plugins, {
        load = function(plugin)
            local data = plugin.spec.data or {}
            local lazy = false

            --Check Event Triggers
            if data.event then
                lazy = true
                vim.api.nvim_create_autocmd(data.event, {
                    group = group,
                    once = true,
                    pattern = data.pattern or "*",
                    callback = function()
                        vim.cmd.packadd(plugin.spec.name)
                        if data.config then
                            data.config(plugin)
                        end
                    end,
                })
            end

            -- Command Triggers
            if data.cmd then
                lazy = true
                vim.api.nvim_create_user_command(data.cmd, function(cmd_args)
                    pcall(vim.api.nvim_del_user_command, data.cmd)
                    vim.cmd.packadd(plugin.spec.name)
                    if data.config then
                        data.config(plugin)
                    end
                    vim.api.nvim_cmd({
                        cmd = data.cmd,
                        args = cmd_args.fargs,
                        bang = cmd_args.bang,
                        nargs = cmd_args.nargs,
                        range = cmd_args.range ~= 0 and { cmd_args.line1, cmd_args.line2 } or nil,
                        count = cmd_args.count ~= -1 and cmd_args.count or nil,
                    }, {})
                end, {
                    nargs = data.nargs,
                    range = data.range,
                    bang = data.bang,
                    complete = data.complete,
                    count = data.count,
                })
            end

            -- -- Key trigger
            -- if data.keys then
            --     lazy = true
            --     local mode, lhs = data.keys[1], data.keys[2]
            --     vim.keymap.set(mode, lhs, function()
            --         vim.keymap.del(mode, lhs)
            --         vim.cmd.packadd(plugin.spec.name)
            --         if data.config then
            --             data.config(plugin)
            --         end
            --         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), "m", false)
            --     end, { desc = data.desc })
            -- end

            if lazy == false then
                vim.cmd.packadd(plugin.spec.name)
                if data.config then
                    data.config(plugin)
                end
            end
        end,
    })
end

return M
