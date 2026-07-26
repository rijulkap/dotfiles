local setup_ts_context
local setup_ts

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
    data = {
        config = function()
            setup_ts_context()
        end,
    },
})

require("pluginmgr").add_plugin({
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
        config = function()
            setup_ts()
        end,
    },
})

setup_ts_context = function()
    require("treesitter-context").setup()
    vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
end

setup_ts = function()
    local parsers = {
        "bash",
        "c",
        "cpp",
        "c_sharp",
        "python",
        "rust",
        "json",
        "markdown",
        "html",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "javascript",
        "typescript",
        "tsx",
    }

    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            local name, kind = ev.data.spec.name, ev.data.kind
            if name == "nvim-treesitter" and kind == "update" then
                if not ev.data.active then
                    vim.cmd.packadd("nvim-treesitter")
                end
                vim.cmd("TSUpdate")
            end
        end,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "bash",
            "sh",
            "c",
            "cpp",
            "cs",
            "python",
            "rust",
            "json",
            "markdown",
            "html",
            "lua",
            "vim",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
        },
        callback = function()
            vim.treesitter.start()
            -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end
