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
    
    -- Dynamic width adjustment settings
    adaptive_width = true,         -- Enable adaptive width based on window size
    min_display_width = 15,        -- Minimum width for any display (just icon + partial title)
    width_ratio = 0.25,            -- Max ratio of statusline width to use
    
    -- Lualine specific settings
    lualine = {
        show_progress = false,     -- Don't show progress in lualine by default
        show_time = false,         -- Don't show time in lualine by default
        show_artist = true,        -- Show artist in lualine
        max_width_ratio = 0.25,    -- Max ratio for lualine component
    },
    priority_levels = {            -- Content priority when space is limited
        icon = 1,                  -- Platform icon (highest priority)
        title = 2,                 -- Song title
        artist = 3,                -- Artist name
        progress = 4,              -- Progress bar
        time = 5                   -- Time info (lowest priority)
    },
    
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