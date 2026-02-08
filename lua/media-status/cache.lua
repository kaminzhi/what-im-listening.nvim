local M = {}

-- Cache storage
local cache = {
    status = "",
    lualine = "",
    last_update = 0,
    last_media_state = nil  -- Cache media state to avoid unnecessary updates
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
    cache.last_media_state = nil
end

function M.update_all(status, lualine, media_state)
    cache.status = status or ""
    cache.lualine = lualine or ""
    cache.last_update = vim.loop.now()
    cache.last_media_state = media_state
end

function M.should_skip_update(media_state)
    if not cache.last_media_state or not media_state then
        return false
    end
    
    return cache.last_media_state.title == media_state.title and
           cache.last_media_state.artist == media_state.artist and
           cache.last_media_state.is_playing == media_state.is_playing and
           math.abs((cache.last_media_state.elapsed or 0) - (media_state.elapsed or 0)) < 2
end

return M