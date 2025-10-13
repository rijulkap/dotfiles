if vim.fn.exists("g:os") == 0 then
    local is_windows = vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1
    if is_windows then
        vim.opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
        -- vim.opt.shell = 'powershell'
        vim.opt.shellcmdflag =
            "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';$PSStyle.OutputRendering='plaintext';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
        vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
        vim.o.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
        vim.opt.shellquote = ""
        vim.opt.shellxquote = ""
    end
end
