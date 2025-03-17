vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typst', 'markdown' },
    callback = function()
        vim.o.wrap = true
        vim.o.spelllang = 'en_us'
        vim.o.spell = true
        vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
        vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })
    end,
    group = vim.api.nvim_create_augroup('TypstSettings', { clear = true }),
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, {
    callback = function()
        if vim.bo.modified and not vim.bo.readonly and vim.fn.expand '%' ~= '' and vim.bo.buftype == '' then
            vim.api.nvim_command 'silent update'
        end
    end,
})

local persistbuffer = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.fn.setbufvar(bufnr, 'bufpersist', 1)
end

vim.api.nvim_create_autocmd({ 'BufRead' }, {
    group = vim.api.nvim_create_augroup('startup', {
        clear = false,
    }),
    pattern = { '*' },
    callback = function()
        vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
            buffer = 0,
            once = true,
            callback = function()
                persistbuffer()
            end,
        })
    end,
})

vim.api.nvim_create_autocmd({ 'VimResized' }, {
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd 'tabdo wincmd ='
        vim.cmd('tabnext ' .. current_tab)
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf', -- Matches both quickfix and location lists
    callback = function()
        vim.bo.buflisted = false
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'oil',
        'checkhealth',
        'dbout',
        'gitsigns-blame',
        'help',
        'lspinfo',
        'notify',
        'qf',
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set('n', 'q', function()
                vim.cmd 'close'
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, {
                buffer = event.buf,
                silent = true,
                desc = 'Quit buffer',
            })
        end)
    end,
})
