local M = {}
local provider = require("what-im-listening.provider")
local utils = require("what-im-listening.utils")

-- Constants
local CONSTANTS = {
    CLI_PATH = "/opt/homebrew/bin/nowplaying-cli",
    TIMEOUT = 3000,
    MEDIA_COMMANDS = {
        playpause = { cmd = "togglePlayPause", name = "Play/Pause", icon = "⏯", command_name = "MediaPlayPause" },
        next = { cmd = "next", name = "Next Track", icon = "⏭", command_name = "MediaNext" },
        previous = { cmd = "previous", name = "Previous Track", icon = "⏮", command_name = "MediaPrevious" }
    },
    DEFAULT_KEYMAPS = {
        play_pause = "<leader>mp",
        next = "<leader>mn",
        previous = "<leader>mP",
        status = "<leader>ms"
    }
}

-- Utility functions for common patterns
local function notify_result(message, level, title)
    vim.notify(message, level or vim.log.levels.INFO, title and { title = title } or {})
end

local function fetch_and_notify(format_func, success_title, error_msg)
    provider.fetch(function(info)
        if info then
            local msg = format_func(info)
            notify_result(msg, vim.log.levels.INFO, success_title)
        else
            notify_result(error_msg, vim.log.levels.WARN)
        end
    end)
end

local function create_command(name, func, desc)
    vim.api.nvim_create_user_command(name, func, desc and { desc = desc } or {})
end

function M.create_commands(config)
    -- Media info commands with unified pattern
    create_command("MediaStatus", function()
        fetch_and_notify(
            function(info) return config.formats.notify_format(info, config) end,
            "Media Status",
            "Nothing playing or media paused"
        )
    end)
    
    create_command("MediaProgress", function()
        provider.fetch(function(info)
            if info and info.progress then
                local msg = config.formats.progress_format(info, config)
                notify_result(msg, vim.log.levels.INFO, "Media Progress")
            else
                notify_result("No media progress available", vim.log.levels.WARN)
            end
        end)
    end)
    
    create_command("MediaPlatforms", function()
        M.show_platforms_info(config)
    end)
    
    -- Media control commands using constants
    for action, info in pairs(CONSTANTS.MEDIA_COMMANDS) do
        create_command(info.command_name, function()
            M.media_control(action)
        end, info.name:lower())
    end
    
    M.setup_keymaps(config)
end

-- Extracted platforms info display function
function M.show_platforms_info(config)
    local platforms_info = "Media Platform Icons:\n"
    for platform, icon in pairs(config.icons.platforms) do
        platforms_info = platforms_info .. icon .. " " .. platform .. "\n"
    end
    platforms_info = platforms_info .. "\nCurrent playing:"
    
    provider.fetch(function(info)
        local final_info
        if info then
            local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
            local status_icon = info.is_playing and config.icons.playing or config.icons.paused
            final_info = platforms_info .. "\n" .. platform_icon .. " " .. status_icon .. " " .. 
                        (info.title or "Unknown") .. " [" .. (info.source or "Unknown") .. "]"
        else
            final_info = platforms_info .. "\nNothing playing"
        end
        notify_result(final_info, vim.log.levels.INFO, "Platform Icons")
    end)
end

-- Optimized media control with constants
function M.media_control(action)
    local action_info = CONSTANTS.MEDIA_COMMANDS[action]
    if not action_info then
        notify_result("Invalid media control action: " .. action, vim.log.levels.ERROR)
        return
    end
    
    vim.system({ CONSTANTS.CLI_PATH, action_info.cmd }, {
        timeout = CONSTANTS.TIMEOUT,
        text = true,
    }, function(result)
        vim.schedule(function()
            local message = result.code == 0 
                and (action_info.name .. " triggered")
                or ("Failed to " .. action .. " media")
            local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
            notify_result(message, level)
        end)
    end)
end

-- Optimized keymap setup with loop
function M.setup_keymaps(config)
    local keymaps = vim.tbl_extend("force", CONSTANTS.DEFAULT_KEYMAPS, config.keymaps or {})
    
    local keymap_configs = {
        { key = keymaps.play_pause, cmd = "MediaPlayPause", desc = "⏯ Toggle play/pause" },
        { key = keymaps.next, cmd = "MediaNext", desc = "⏭ Next track" },
        { key = keymaps.previous, cmd = "MediaPrevious", desc = "⏮ Previous track" },
        { key = keymaps.status, cmd = "MediaStatus", desc = "🎵 Show media status" }
    }
    
    for _, config_item in ipairs(keymap_configs) do
        if config_item.key then
            vim.keymap.set('n', config_item.key, '<cmd>' .. config_item.cmd .. '<cr>', 
                { desc = config_item.desc, silent = true })
        end
    end
end

return M