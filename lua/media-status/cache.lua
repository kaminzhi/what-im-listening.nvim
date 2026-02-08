local M = {}

-- Cache storage
local cache = {
    status = "",
    lualine = "",
    last_update = 0
}

function M.set_status(status)
    cache.status = status or ""
    cache.last_update = vim.loop.now()
end

function M.set_lualine(lualine)
    cache.lualine = lualine or ""
    cache.last_update = vim.loop.now()
end

function M.get_status()
    return cache.status
end

function M.get_lualine()
    return cache.lualine
end

function M.get_last_update()
    return cache.last_update
end

function M.clear()
    cache.status = ""
    cache.lualine = ""
    cache.last_update = 0
end

function M.update_all(status, lualine)
    cache.status = status or ""
    cache.lualine = lualine or ""
    cache.last_update = vim.loop.now()
end

return M