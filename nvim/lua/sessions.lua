M = {}

function M.get_hashed_session_name()
    local cwd = vim.fn.getcwd()
    local hash = vim.fn.sha256(cwd)
    return hash
end

local function get_session_filepath(name)
    local session_dir = require("mini.sessions").config.directory
    return session_dir .. "/" .. name
end

function M.try_read_session()
    local session_name = M.get_hashed_session_name()
    local session_file = get_session_filepath(session_name)

    if vim.fn.filereadable(session_file) == 1 then
        require("mini.sessions").read(session_name)
    else
        vim.notify("No session found for current directory", vim.log.levels.WARN, { title = "Session" })
    end
end

return M
