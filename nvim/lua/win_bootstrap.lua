if vim.fn.exists 'g:os' == 0 then
    local is_windows = vim.fn.has 'win64' == 1 or vim.fn.has 'win32' == 1 or vim.fn.has 'win16' == 1
    if is_windows then
        -- vim.opt.shell = vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell'
        vim.opt.shell = 'powershell'
        vim.opt.shellcmdflag =
        '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
        vim.opt.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
        vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
        vim.opt.shellquote = ''
        vim.opt.shellxquote = ''
    end
end
