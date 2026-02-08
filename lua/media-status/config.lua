local M = {}
local icons = require("media-status.icons")

M.defaults = {
    update_interval = 1000,  -- Update interval (ms)
    max_width = 0,           -- Max width for status bar (0=unlimited)
    
    show_progress = true,
    show_time = true,
    show_artist = true,
    show_album = false,
    
    icons = icons.get_all(),
    
    separators = {
        artist = " - ",
        time = "/",
        progress_wrap = "[%s]"
    },
    
    progress_width = 15,
}

M.current = vim.deepcopy(M.defaults)

function M.setup(user_config)
    M.current = vim.tbl_deep_extend("force", M.defaults, user_config or {})
    return M.current
end

function M.update_formats(formats)
    M.current.formats = formats
end

function M.get()
    return M.current
end

return M