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
end

return M