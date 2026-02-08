local M = {}
local icons = require("media-status.icons")

local CONSTANTS = {
    DEFAULT_UPDATE_INTERVAL = 5000, -- Optimized interval
    DEFAULT_PROGRESS_WIDTH = 15,
    DEFAULT_KEYMAPS = {
        play_pause = "<leader>mp",
        next = "<leader>mn", 
        previous = "<leader>mP",
        status = "<leader>ms"
    },
    DEFAULT_SEPARATORS = {
        artist = " - ",
        time = "/",
        progress_wrap = "[%s]"
    }
}

M.defaults = {
    update_interval = CONSTANTS.DEFAULT_UPDATE_INTERVAL,
    max_width = 0,
    
    show_progress = true,
    show_time = true,
    show_artist = true,
    show_album = false,
    
    icons = icons.get_all(),
    separators = CONSTANTS.DEFAULT_SEPARATORS,
    progress_width = CONSTANTS.DEFAULT_PROGRESS_WIDTH,
    keymaps = CONSTANTS.DEFAULT_KEYMAPS
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