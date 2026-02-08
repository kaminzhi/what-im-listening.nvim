local M = {}
local provider = require("media-status.provider")
local utils = require("media-status.utils")

function M.create_commands(config)
    -- MediaStatus command
    vim.api.nvim_create_user_command("MediaStatus", function()
        provider.fetch(function(info)
            if info then
                local msg = config.formats.notify_format(info, config)
                vim.notify(msg, vim.log.levels.INFO, { title = "Media Status" })
            else
                vim.notify("Nothing playing or media paused", vim.log.levels.WARN)
            end
        end)
    end, {})
    
    -- MediaProgress command
    vim.api.nvim_create_user_command("MediaProgress", function()
        provider.fetch(function(info)
            if info and info.progress then
                local progress_msg = config.formats.progress_format(info, config)
                vim.notify(progress_msg, vim.log.levels.INFO, { title = "Media Progress" })
            else
                vim.notify("No media progress available", vim.log.levels.WARN)
            end
        end)
    end, {})
    
    -- MediaPlatforms command
    vim.api.nvim_create_user_command("MediaPlatforms", function()
        local platforms_info = "Media Platform Icons:\n"
        for platform, icon in pairs(config.icons.platforms) do
            platforms_info = platforms_info .. icon .. " " .. platform .. "\n"
        end
        platforms_info = platforms_info .. "\nCurrent playing:"
        
        provider.fetch(function(info)
            if info then
                local platform_icon = config.icons.platforms[info.source] or config.icons.platforms["Unknown"]
                local status_icon = info.is_playing and config.icons.playing or config.icons.paused
                platforms_info = platforms_info .. "\n" .. platform_icon .. " " .. status_icon .. " " .. 
                               (info.title or "Unknown") .. " [" .. (info.source or "Unknown") .. "]"
            else
                platforms_info = platforms_info .. "\nNothing playing"
            end
            vim.notify(platforms_info, vim.log.levels.INFO, { title = "Platform Icons" })
        end)
    end, {})
    
    -- Media Control Commands
    vim.api.nvim_create_user_command("MediaPlayPause", function()
        M.media_control("playpause")
    end, { desc = "Toggle play/pause" })
    
    vim.api.nvim_create_user_command("MediaNext", function()
        M.media_control("next")
    end, { desc = "Skip to next track" })
    
    vim.api.nvim_create_user_command("MediaPrevious", function()
        M.media_control("previous")
    end, { desc = "Skip to previous track" })
    
    -- Create key mappings if enabled
    M.setup_keymaps(config)
end

-- Media control function using nowplaying-cli
function M.media_control(action)
    local cmd_map = {
        playpause = "togglePlayPause",
        next = "next",
        previous = "previous"
    }
    
    local command = cmd_map[action]
    if not command then
        vim.notify("Invalid media control action: " .. action, vim.log.levels.ERROR)
        return
    end
    
    vim.system({ "/opt/homebrew/bin/nowplaying-cli", command }, {
        timeout = 3000,
        text = true,
    }, function(result)
        vim.schedule(function()
            if result.code == 0 then
                local action_names = {
                    playpause = "Play/Pause",
                    next = "Next Track",
                    previous = "Previous Track"
                }
                vim.notify(action_names[action] .. " triggered", vim.log.levels.INFO)
            else
                vim.notify("Failed to " .. action .. " media", vim.log.levels.ERROR)
            end
        end)
    end)
end

-- Setup keyboard mappings
function M.setup_keymaps(config)
    local keymaps = config.keymaps or {}
    
    local default_keymaps = {
        play_pause = "<leader>mp",
        next = "<leader>mn",
        previous = "<leader>mP",
        status = "<leader>ms"
    }
    
    keymaps = vim.tbl_extend("force", default_keymaps, keymaps)
    
    -- Set up the mappings
    if keymaps.play_pause then
        vim.keymap.set('n', keymaps.play_pause, '<cmd>MediaPlayPause<cr>', 
            { desc = '⏯ Toggle play/pause', silent = true })
    end
    
    if keymaps.next then
        vim.keymap.set('n', keymaps.next, '<cmd>MediaNext<cr>', 
            { desc = '⏭ Next track', silent = true })
    end
    
    if keymaps.previous then
        vim.keymap.set('n', keymaps.previous, '<cmd>MediaPrevious<cr>', 
            { desc = '⏮ Previous track', silent = true })
    end
    
    if keymaps.status then
        vim.keymap.set('n', keymaps.status, '<cmd>MediaStatus<cr>', 
            { desc = 'Show media status', silent = true })
    end
end

return M